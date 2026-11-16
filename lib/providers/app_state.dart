import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/product.dart';
import '../models/customer.dart';
import '../models/invoice.dart';
import '../models/supplier.dart';
import '../models/shop_settings.dart';
import '../services/storage_service.dart';

class AppState extends ChangeNotifier {
  final StorageService _storage = StorageService();
  final Uuid _uuid = const Uuid();

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  ShopSettings _settings = ShopSettings();
  ShopSettings get settings => _settings;

  List<Product> _products = [];
  List<Product> get products => _products;

  List<Customer> _customers = [];
  List<Customer> get customers => _customers;

  List<Supplier> _suppliers = [];
  List<Supplier> get suppliers => _suppliers;

  List<Invoice> _invoices = [];
  List<Invoice> get invoices => _invoices;

  // Active View Navigation Index
  int _currentViewIndex = 0;
  int get currentViewIndex => _currentViewIndex;

  void setViewIndex(int index) {
    _currentViewIndex = index;
    notifyListeners();
  }

  // --- POS / Active Cart State ---
  final List<InvoiceItem> _cart = [];
  List<InvoiceItem> get cart => List.unmodifiable(_cart);

  Customer? _cartCustomer;
  Customer? get cartCustomer => _cartCustomer;

  String _customerName = 'Walk-in Customer';
  String _customerPhone = '';
  String _customerAddress = '';
  String _customerGstin = '';
  String _paymentMode = 'Cash';
  String _paymentRef = '';
  double _cartDiscount = 0.0;
  bool _cartIsInterState = false;

  String get customerName => _customerName;
  String get customerPhone => _customerPhone;
  String get customerAddress => _customerAddress;
  String get customerGstin => _customerGstin;
  String get paymentMode => _paymentMode;
  String get paymentRef => _paymentRef;
  double get cartDiscount => _cartDiscount;
  bool get cartIsInterState => _cartIsInterState;

  AppState() {
    loadAllData();
  }

  Future<void> loadAllData() async {
    _isLoading = true;
    notifyListeners();

    _settings = await _storage.loadSettings();
    _products = await _storage.loadProducts();
    _customers = await _storage.loadCustomers();
    _suppliers = await _storage.loadSuppliers();
    _invoices = await _storage.loadInvoices();

    _cartIsInterState = _settings.isInterState;

    _isLoading = false;
    notifyListeners();
  }

  // --- Cart Calculations ---
  double get cartSubtotal => _cart.fold(0.0, (sum, item) => sum + item.taxableAmount);

  double get cartCgst => _cartIsInterState
      ? 0.0
      : _cart.fold(0.0, (sum, item) => sum + item.cgstAmount);

  double get cartSgst => _cartIsInterState
      ? 0.0
      : _cart.fold(0.0, (sum, item) => sum + item.sgstAmount);

  double get cartIgst => _cartIsInterState
      ? _cart.fold(0.0, (sum, item) => sum + item.igstAmount)
      : 0.0;

  double get cartTotalTax => cartCgst + cartSgst + cartIgst;

  double get cartRawGrandTotal => (cartSubtotal + cartTotalTax) - _cartDiscount;

  double get cartGrandTotal => cartRawGrandTotal.roundToDouble();

  double get cartRoundOff => cartGrandTotal - cartRawGrandTotal;

  // --- Cart Actions ---
  void selectCustomer(Customer? customer) {
    _cartCustomer = customer;
    if (customer != null) {
      _customerName = customer.name;
      _customerPhone = customer.phone;
      _customerAddress = customer.address ?? '';
      _customerGstin = customer.gstin ?? '';
    } else {
      _customerName = 'Walk-in Customer';
      _customerPhone = '';
      _customerAddress = '';
      _customerGstin = '';
    }
    notifyListeners();
  }

  void updateCustomerDetails({
    required String name,
    required String phone,
    String address = '',
    String gstin = '',
  }) {
    _customerName = name;
    _customerPhone = phone;
    _customerAddress = address;
    _customerGstin = gstin;
    notifyListeners();
  }

  void setPaymentMode(String mode) {
    _paymentMode = mode;
    notifyListeners();
  }

  void setPaymentRef(String ref) {
    _paymentRef = ref;
    notifyListeners();
  }

  void setCartDiscount(double discount) {
    _cartDiscount = discount;
    notifyListeners();
  }

  void setCartInterState(bool isInterState) {
    _cartIsInterState = isInterState;
    notifyListeners();
  }

  int getCartQuantityForProduct(String productId) {
    return _cart
        .where((item) => item.productId == productId)
        .fold(0, (sum, item) => sum + item.quantity);
  }

  int getAvailableStockForProduct(String productId) {
    final pList = _products.where((p) => p.id == productId);
    if (pList.isEmpty) return 0;
    final p = pList.first;
    final inCart = getCartQuantityForProduct(productId);
    return (p.stockQuantity - inCart).clamp(0, p.stockQuantity);
  }

  bool addToCart(Product product) {
    // Check if product has available stock
    final currentQtyInCart = getCartQuantityForProduct(product.id);

    if (currentQtyInCart >= product.stockQuantity) {
      return false; // Stock limit reached
    }

    final existingIndex =
        _cart.indexWhere((item) => item.productId == product.id);

    if (existingIndex >= 0) {
      _cart[existingIndex].quantity += 1;
    } else {
      // Calculate unit rate before tax if selling price is tax-inclusive
      // For standard Indian retail, sellingPrice is MRP. Base rate = sellingPrice / (1 + gstRate/100)
      final basePrice =
          product.sellingPrice / (1.0 + (product.gstRate / 100.0));

      _cart.add(InvoiceItem(
        productId: product.id,
        productName: product.name,
        barcode: product.barcode,
        hsnCode: product.hsnCode,
        quantity: 1,
        unit: product.unit,
        unitPrice: double.parse(basePrice.toStringAsFixed(2)),
        discount: 0.0,
        gstRate: product.gstRate,
        warranty: product.warranty,
        serialNumbers: [],
      ));
    }
    notifyListeners();
    return true;
  }

  void updateCartQuantity(int index, int quantity) {
    if (index >= 0 && index < _cart.length) {
      if (quantity <= 0) {
        _cart.removeAt(index);
      } else {
        // Verify stock limit
        final product = _products
            .firstWhere((p) => p.id == _cart[index].productId, orElse: () => _products.first);
        if (quantity <= product.stockQuantity) {
          _cart[index].quantity = quantity;
        }
      }
      notifyListeners();
    }
  }

  void updateCartItemDiscount(int index, double discount) {
    if (index >= 0 && index < _cart.length) {
      _cart[index].discount = discount;
      notifyListeners();
    }
  }

  void updateCartItemSerials(int index, List<String> serials) {
    if (index >= 0 && index < _cart.length) {
      _cart[index].serialNumbers = serials;
      notifyListeners();
    }
  }

  void removeFromCart(int index) {
    if (index >= 0 && index < _cart.length) {
      _cart.removeAt(index);
      notifyListeners();
    }
  }

  void clearCart() {
    _cart.clear();
    _cartCustomer = null;
    _customerName = 'Walk-in Customer';
    _customerPhone = '';
    _customerAddress = '';
    _customerGstin = '';
    _paymentMode = 'Cash';
    _paymentRef = '';
    _cartDiscount = 0.0;
    _cartIsInterState = _settings.isInterState;
    notifyListeners();
  }

  // --- Complete Sale / Create Invoice ---
  Future<Invoice?> completeSale({
    required double amountPaid,
    String? customNotes,
  }) async {
    if (_cart.isEmpty) return null;

    final invoiceNum =
        '${_settings.invoicePrefix}${_settings.nextInvoiceNumber}';
    final now = DateTime.now();

    final due = (cartGrandTotal - amountPaid).clamp(0.0, double.infinity);
    final status = due <= 0 ? 'Paid' : (amountPaid > 0 ? 'Partial' : 'Due');

    final invoice = Invoice(
      id: _uuid.v4(),
      invoiceNumber: invoiceNum,
      date: now,
      customerName: _customerName.trim().isEmpty ? 'Walk-in Customer' : _customerName.trim(),
      customerPhone: _customerPhone.trim(),
      customerAddress: _customerAddress.trim().isEmpty ? null : _customerAddress.trim(),
      customerGstin: _customerGstin.trim().isEmpty ? null : _customerGstin.trim(),
      items: List.from(_cart),
      subtotal: cartSubtotal,
      totalDiscount: _cartDiscount,
      totalCgst: cartCgst,
      totalSgst: cartSgst,
      totalIgst: cartIgst,
      roundOff: cartRoundOff,
      grandTotal: cartGrandTotal,
      amountPaid: amountPaid,
      amountDue: due,
      paymentMode: _paymentMode,
      paymentRef: _paymentRef.trim().isEmpty ? null : _paymentRef.trim(),
      isInterState: _cartIsInterState,
      status: status,
      notes: customNotes,
    );

    // 1. Deduct Product Inventory Stock
    for (final item in _cart) {
      final pIndex = _products.indexWhere((p) => p.id == item.productId);
      if (pIndex >= 0) {
        _products[pIndex].stockQuantity =
            (_products[pIndex].stockQuantity - item.quantity).clamp(0, 999999);
      }
    }
    await _storage.saveProducts(_products);

    // 2. Update / Add Customer
    if (_cartCustomer != null) {
      final cIndex = _customers.indexWhere((c) => c.id == _cartCustomer!.id);
      if (cIndex >= 0) {
        _customers[cIndex].totalPurchases += cartGrandTotal;
        _customers[cIndex].dueBalance += due;
      }
    } else if (_customerPhone.isNotEmpty && _customerName != 'Walk-in Customer') {
      // Find or create customer
      final existingCustIndex =
          _customers.indexWhere((c) => c.phone == _customerPhone);
      if (existingCustIndex >= 0) {
        _customers[existingCustIndex].totalPurchases += cartGrandTotal;
        _customers[existingCustIndex].dueBalance += due;
      } else {
        final newCust = Customer(
          id: _uuid.v4(),
          name: _customerName,
          phone: _customerPhone,
          address: _customerAddress,
          gstin: _customerGstin,
          totalPurchases: cartGrandTotal,
          dueBalance: due,
        );
        _customers.add(newCust);
      }
    }
    await _storage.saveCustomers(_customers);

    // 3. Increment Invoice Number
    _settings.nextInvoiceNumber += 1;
    await _storage.saveSettings(_settings);

    // 4. Save Invoice
    _invoices.insert(0, invoice);
    await _storage.saveInvoices(_invoices);

    clearCart();
    notifyListeners();
    return invoice;
  }

  // --- Product Management ---
  Future<void> addProduct(Product product) async {
    _products.add(product);
    await _storage.saveProducts(_products);
    notifyListeners();
  }

  Future<void> updateProduct(Product product) async {
    final idx = _products.indexWhere((p) => p.id == product.id);
    if (idx >= 0) {
      _products[idx] = product;
      await _storage.saveProducts(_products);
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    _products.removeWhere((p) => p.id == id);
    await _storage.saveProducts(_products);
    notifyListeners();
  }

  Future<void> adjustStock(String productId, int newQuantity) async {
    final idx = _products.indexWhere((p) => p.id == productId);
    if (idx >= 0) {
      _products[idx].stockQuantity = newQuantity;
      await _storage.saveProducts(_products);
      notifyListeners();
    }
  }

  Future<void> restockProduct(
    String productId,
    int addQuantity, {
    double? newCostPrice,
    double? newSellingPrice,
  }) async {
    final idx = _products.indexWhere((p) => p.id == productId);
    if (idx >= 0) {
      final current = _products[idx];
      _products[idx] = current.copyWith(
        stockQuantity: current.stockQuantity + addQuantity,
        costPrice: newCostPrice ?? current.costPrice,
        sellingPrice: newSellingPrice ?? current.sellingPrice,
      );
      await _storage.saveProducts(_products);
      notifyListeners();
    }
  }

  Future<void> clearAllData() async {
    await _storage.clearAllData();
    _cart.clear();
    await loadAllData();
  }

  // --- Customer Management ---
  Future<void> addCustomer(Customer customer) async {
    _customers.add(customer);
    await _storage.saveCustomers(_customers);
    notifyListeners();
  }

  Future<void> updateCustomer(Customer customer) async {
    final idx = _customers.indexWhere((c) => c.id == customer.id);
    if (idx >= 0) {
      _customers[idx] = customer;
      await _storage.saveCustomers(_customers);
      notifyListeners();
    }
  }

  Future<void> settleCustomerDue(String customerId, double amountPaid) async {
    final idx = _customers.indexWhere((c) => c.id == customerId);
    if (idx >= 0) {
      _customers[idx].dueBalance =
          (_customers[idx].dueBalance - amountPaid).clamp(0.0, double.infinity);
      await _storage.saveCustomers(_customers);
      notifyListeners();
    }
  }

  // --- Supplier Management ---
  Future<void> addSupplier(Supplier supplier) async {
    _suppliers.add(supplier);
    await _storage.saveSuppliers(_suppliers);
    notifyListeners();
  }

  Future<void> updateSupplier(Supplier supplier) async {
    final idx = _suppliers.indexWhere((s) => s.id == supplier.id);
    if (idx >= 0) {
      _suppliers[idx] = supplier;
      await _storage.saveSuppliers(_suppliers);
      notifyListeners();
    }
  }

  Future<void> deleteSupplier(String id) async {
    _suppliers.removeWhere((s) => s.id == id);
    await _storage.saveSuppliers(_suppliers);
    notifyListeners();
  }

  // --- Settings Management ---
  Future<void> updateSettings(ShopSettings newSettings) async {
    _settings = newSettings;
    await _storage.saveSettings(_settings);
    notifyListeners();
  }

  Future<String> exportBackup() async {
    return await _storage.exportFullBackup();
  }

  Future<bool> importBackup(String jsonStr) async {
    final success = await _storage.importFullBackup(jsonStr);
    if (success) {
      await loadAllData();
    }
    return success;
  }

  // --- Analytics & Statistics ---
  double get todaySalesRevenue {
    final now = DateTime.now();
    return _invoices
        .where((inv) =>
            inv.date.year == now.year &&
            inv.date.month == now.month &&
            inv.date.day == now.day &&
            inv.status != 'Cancelled')
        .fold(0.0, (sum, inv) => sum + inv.grandTotal);
  }

  int get todaySalesCount {
    final now = DateTime.now();
    return _invoices
        .where((inv) =>
            inv.date.year == now.year &&
            inv.date.month == now.month &&
            inv.date.day == now.day &&
            inv.status != 'Cancelled')
        .length;
  }

  double get monthlySalesRevenue {
    final now = DateTime.now();
    return _invoices
        .where((inv) =>
            inv.date.year == now.year &&
            inv.date.month == now.month &&
            inv.status != 'Cancelled')
        .fold(0.0, (sum, inv) => sum + inv.grandTotal);
  }

  double get totalInventoryCost =>
      _products.fold(0.0, (sum, p) => sum + p.totalStockCost);

  double get totalInventoryValue =>
      _products.fold(0.0, (sum, p) => sum + p.totalStockValue);

  List<Product> get lowStockProducts =>
      _products.where((p) => p.isLowStock && !p.isOutOfStock).toList();

  List<Product> get outOfStockProducts =>
      _products.where((p) => p.isOutOfStock).toList();

  double get totalCustomerDues =>
      _customers.fold(0.0, (sum, c) => sum + c.dueBalance);

  List<Invoice> get recentInvoices => _invoices.take(8).toList();

  static const List<String> defaultCategories = [
    'Paint',
    'Electrical',
    'Hardware',
    'Plumbing',
  ];

  List<String> get categories {
    final set = Set<String>.from(defaultCategories);
    for (final p in _products) {
      if (p.category.trim().isNotEmpty) {
        set.add(p.category.trim());
      }
    }
    return set.toList();
  }
}

