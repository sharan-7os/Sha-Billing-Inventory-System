import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../models/customer.dart';
import '../models/invoice.dart';
import '../models/supplier.dart';
import '../models/shop_settings.dart';

class StorageService {
  static const String _keyProducts = 'sha_products';
  static const String _keyCustomers = 'sha_customers';
  static const String _keyInvoices = 'sha_invoices';
  static const String _keySuppliers = 'sha_suppliers';
  static const String _keySettings = 'sha_settings';
  static const String _keySamplesCleared = 'sha_samples_cleared_v2';

  // Load Settings
  Future<ShopSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keySettings);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        return ShopSettings.fromJson(jsonDecode(jsonStr));
      } catch (_) {}
    }
    final defaultSettings = ShopSettings();
    await saveSettings(defaultSettings);
    return defaultSettings;
  }

  // Save Settings
  Future<void> saveSettings(ShopSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySettings, jsonEncode(settings.toJson()));
  }

  // Load Products (Fresh start: empty by default)
  Future<List<Product>> loadProducts() async {
    final prefs = await SharedPreferences.getInstance();
    await _checkOneTimeSampleWipe(prefs);

    final jsonStr = prefs.getString(_keyProducts);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final List<dynamic> list = jsonDecode(jsonStr);
        return list.map((e) => Product.fromJson(e)).toList();
      } catch (_) {}
    }
    return [];
  }

  // Save Products
  Future<void> saveProducts(List<Product> products) async {
    final prefs = await SharedPreferences.getInstance();
    final list = products.map((e) => e.toJson()).toList();
    await prefs.setString(_keyProducts, jsonEncode(list));
  }

  // Load Customers (Fresh start: only standard Walk-in Customer by default)
  Future<List<Customer>> loadCustomers() async {
    final prefs = await SharedPreferences.getInstance();
    await _checkOneTimeSampleWipe(prefs);

    final jsonStr = prefs.getString(_keyCustomers);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final List<dynamic> list = jsonDecode(jsonStr);
        return list.map((e) => Customer.fromJson(e)).toList();
      } catch (_) {}
    }
    final defaultCust = [
      Customer(
        id: 'cust-walkin',
        name: 'Walk-in Customer',
        phone: '',
        email: '',
        address: 'Counter',
        totalPurchases: 0.0,
        dueBalance: 0.0,
      )
    ];
    await saveCustomers(defaultCust);
    return defaultCust;
  }

  // Save Customers
  Future<void> saveCustomers(List<Customer> customers) async {
    final prefs = await SharedPreferences.getInstance();
    final list = customers.map((e) => e.toJson()).toList();
    await prefs.setString(_keyCustomers, jsonEncode(list));
  }

  // Load Invoices (Fresh start: empty by default)
  Future<List<Invoice>> loadInvoices() async {
    final prefs = await SharedPreferences.getInstance();
    await _checkOneTimeSampleWipe(prefs);

    final jsonStr = prefs.getString(_keyInvoices);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final List<dynamic> list = jsonDecode(jsonStr);
        return list.map((e) => Invoice.fromJson(e)).toList();
      } catch (_) {}
    }
    return [];
  }

  // Save Invoices
  Future<void> saveInvoices(List<Invoice> invoices) async {
    final prefs = await SharedPreferences.getInstance();
    final list = invoices.map((e) => e.toJson()).toList();
    await prefs.setString(_keyInvoices, jsonEncode(list));
  }

  // Load Suppliers (Fresh start: empty by default)
  Future<List<Supplier>> loadSuppliers() async {
    final prefs = await SharedPreferences.getInstance();
    await _checkOneTimeSampleWipe(prefs);

    final jsonStr = prefs.getString(_keySuppliers);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final List<dynamic> list = jsonDecode(jsonStr);
        return list.map((e) => Supplier.fromJson(e)).toList();
      } catch (_) {}
    }
    return [];
  }

  // Save Suppliers
  Future<void> saveSuppliers(List<Supplier> suppliers) async {
    final prefs = await SharedPreferences.getInstance();
    final list = suppliers.map((e) => e.toJson()).toList();
    await prefs.setString(_keySuppliers, jsonEncode(list));
  }

  // One-time automatic cleanup to delete all previous samples
  Future<void> _checkOneTimeSampleWipe(SharedPreferences prefs) async {
    if (prefs.getBool(_keySamplesCleared) != true) {
      await clearAllData();
      await prefs.setBool(_keySamplesCleared, true);
    }
  }

  // Clear all data completely for fresh start
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyProducts);
    await prefs.remove(_keyInvoices);
    await prefs.remove(_keySuppliers);

    final defaultCust = [
      Customer(
        id: 'cust-walkin',
        name: 'Walk-in Customer',
        phone: '',
        email: '',
        address: 'Counter',
        totalPurchases: 0.0,
        dueBalance: 0.0,
      )
    ];
    await prefs.setString(_keyCustomers,
        jsonEncode(defaultCust.map((e) => e.toJson()).toList()));

    // Reset invoice sequence
    final jsonSettings = prefs.getString(_keySettings);
    if (jsonSettings != null) {
      try {
        final settings = ShopSettings.fromJson(jsonDecode(jsonSettings));
        settings.nextInvoiceNumber = 1001;
        await prefs.setString(_keySettings, jsonEncode(settings.toJson()));
      } catch (_) {}
    }
    await prefs.setBool(_keySamplesCleared, true);
  }

  // Export full database as JSON
  Future<String> exportFullBackup() async {
    final prefs = await SharedPreferences.getInstance();
    final backup = {
      'timestamp': DateTime.now().toIso8601String(),
      'settings': prefs.getString(_keySettings),
      'products': prefs.getString(_keyProducts),
      'customers': prefs.getString(_keyCustomers),
      'invoices': prefs.getString(_keyInvoices),
      'suppliers': prefs.getString(_keySuppliers),
    };
    return jsonEncode(backup);
  }

  // Import full database
  Future<bool> importFullBackup(String jsonBackup) async {
    try {
      final Map<String, dynamic> data = jsonDecode(jsonBackup);
      final prefs = await SharedPreferences.getInstance();
      if (data['settings'] != null) await prefs.setString(_keySettings, data['settings']);
      if (data['products'] != null) await prefs.setString(_keyProducts, data['products']);
      if (data['customers'] != null) await prefs.setString(_keyCustomers, data['customers']);
      if (data['invoices'] != null) await prefs.setString(_keyInvoices, data['invoices']);
      if (data['suppliers'] != null) await prefs.setString(_keySuppliers, data['suppliers']);
      return true;
    } catch (e) {
      return false;
    }
  }
}
