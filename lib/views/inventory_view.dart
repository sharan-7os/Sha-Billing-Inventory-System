import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/product.dart';
import '../providers/app_state.dart';
import '../widgets/header_bar.dart';

class InventoryView extends StatefulWidget {
  const InventoryView({super.key});

  @override
  State<InventoryView> createState() => _InventoryViewState();
}

class _InventoryViewState extends State<InventoryView> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _stockFilter = 'All'; // All, Low Stock, Out of Stock
  final Uuid _uuid = const Uuid();

  static const List<String> primaryCategories = [
    'Paint',
    'Electrical',
    'Hardware',
    'Plumbing',
  ];

  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'paint':
        return const Color(0xFF9333EA); // Purple 600
      case 'electrical':
        return const Color(0xFFD97706); // Amber 600
      case 'hardware':
        return const Color(0xFF2563EB); // Blue 600
      case 'plumbing':
        return const Color(0xFF0D9488); // Teal 600
      default:
        return const Color(0xFF475569); // Slate 600
    }
  }

  static IconData getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'paint':
        return Icons.format_paint_rounded;
      case 'electrical':
        return Icons.bolt_rounded;
      case 'hardware':
        return Icons.handyman_rounded;
      case 'plumbing':
        return Icons.plumbing_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final currency = NumberFormat('#,##,##0.00');

    // Filter products
    final filtered = state.products.where((p) {
      final query = _searchController.text.toLowerCase();
      final matchesQuery = query.isEmpty ||
          p.name.toLowerCase().contains(query) ||
          p.barcode.toLowerCase().contains(query) ||
          p.brand.toLowerCase().contains(query) ||
          p.hsnCode.toLowerCase().contains(query);

      final matchesCat =
          _selectedCategory == 'All' || p.category == _selectedCategory;

      final matchesStock = _stockFilter == 'All' ||
          (_stockFilter == 'Low Stock' && p.isLowStock && !p.isOutOfStock) ||
          (_stockFilter == 'Out of Stock' && p.isOutOfStock);

      return matchesQuery && matchesCat && matchesStock;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Column(
        children: [
          HeaderBar(
            title: 'Inventory & Stock Management',
            subtitle:
                '${state.products.length} Products in catalog • Paint, Electrical, Hardware & Plumbing',
            actions: [
              ElevatedButton.icon(
                onPressed: () => _showAddEditProductDialog(context, state),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Product & Stock'),
              ),
            ],
          ),

          // Search and 4 Category Filters Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            color: Colors.white,
            child: Row(
              children: [
                // Search
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText:
                          'Search product name, product code, brand, or HSN code...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Category Dropdown
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    isDense: true,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: ['All', ...state.categories].map((c) {
                      return DropdownMenuItem(
                        value: c,
                        child: Row(
                          children: [
                            if (c != 'All') ...[
                              Icon(getCategoryIcon(c),
                                  size: 16, color: getCategoryColor(c)),
                              const SizedBox(width: 8),
                            ],
                            Text(c),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedCategory = val);
                    },
                  ),
                ),
                const SizedBox(width: 16),

                // Stock Filter Dropdown
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    initialValue: _stockFilter,
                    isDense: true,
                    decoration: InputDecoration(
                      labelText: 'Stock Status',
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'All', child: Text('All Stock')),
                      DropdownMenuItem(
                          value: 'Low Stock', child: Text('Low Stock Alerts')),
                      DropdownMenuItem(
                          value: 'Out of Stock',
                          child: Text('Out of Stock (0)')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _stockFilter = val);
                    },
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Products Table or Empty State
          Expanded(
            child: state.products.isEmpty
                ? _buildEmptyState(context, state)
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Table(
                          border: TableBorder(
                            horizontalInside: BorderSide(
                                color: Colors.grey.shade200, width: 1),
                          ),
                          columnWidths: const {
                            0: FlexColumnWidth(1.2), // SKU
                            1: FlexColumnWidth(2.7), // Name & Brand
                            2: FlexColumnWidth(1.5), // Category
                            3: FlexColumnWidth(1.1), // HSN
                            4: FlexColumnWidth(1.3), // Cost Price
                            5: FlexColumnWidth(1.4), // Selling Price
                            6: FlexColumnWidth(1.0), // GST %
                            7: FlexColumnWidth(1.8), // Stock & Edit Button
                            8: FlexColumnWidth(1.3), // Actions
                          },
                          children: [
                            TableRow(
                              decoration:
                                  BoxDecoration(color: Colors.grey.shade100),
                              children: [
                                _buildTh('Product Code'),
                                _buildTh('Product Description'),
                                _buildTh('Category'),
                                _buildTh('HSN'),
                                _buildTh('Cost Price'),
                                _buildTh('Selling Price (MRP)'),
                                _buildTh('GST %', align: TextAlign.center),
                                _buildTh('Stock Quantity',
                                    align: TextAlign.center),
                                _buildTh('Actions', align: TextAlign.center),
                              ],
                            ),
                            ...filtered.map((p) {
                              final catColor = getCategoryColor(p.category);
                              final catIcon = getCategoryIcon(p.category);

                              return TableRow(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 12),
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 7, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.blueGrey.shade50,
                                        borderRadius:
                                            BorderRadius.circular(4),
                                        border: Border.all(
                                            color: Colors.blueGrey.shade200,
                                            width: 0.8),
                                      ),
                                      child: Text(
                                        p.barcode,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'monospace',
                                          color: Colors.blueGrey.shade900,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          p.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: Color(0xFF0F172A),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            Text(
                                              'Brand: ${p.brand}',
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey.shade600),
                                            ),
                                            if (p.warranty.isNotEmpty &&
                                                p.warranty != 'No Warranty') ...[
                                              const SizedBox(width: 8),
                                              Text(
                                                '• Warranty: ${p.warranty}',
                                                style: TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.teal.shade700,
                                                    fontWeight: FontWeight.w500),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Category Badge
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14, horizontal: 10),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color:
                                            catColor.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                            color: catColor
                                                .withValues(alpha: 0.3)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(catIcon,
                                              size: 14, color: catColor),
                                          const SizedBox(width: 6),
                                          Text(
                                            p.category,
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: catColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  _buildTd(p.hsnCode),
                                  _buildTd('₹ ${currency.format(p.costPrice)}'),
                                  _buildTd(
                                      '₹ ${currency.format(p.sellingPrice)}',
                                      isBold: true,
                                      color: const Color(0xFF2563EB)),
                                  _buildTd('${p.gstRate.toInt()}%',
                                      align: TextAlign.center),
                                  // Stock and Direct Edit Button
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 8),
                                    child: Center(
                                      child: OutlinedButton.icon(
                                        onPressed: () =>
                                            _showStockEditDialog(
                                                context, state, p),
                                        style: OutlinedButton.styleFrom(
                                          visualDensity: VisualDensity.compact,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 6),
                                          backgroundColor: p.isOutOfStock
                                              ? Colors.red.shade50
                                              : p.isLowStock
                                                  ? Colors.orange.shade50
                                                  : Colors.green.shade50,
                                          side: BorderSide(
                                            color: p.isOutOfStock
                                                ? Colors.red.shade300
                                                : p.isLowStock
                                                    ? Colors.orange.shade300
                                                    : Colors.green.shade300,
                                          ),
                                        ),
                                        icon: Icon(
                                          Icons.edit_note_rounded,
                                          size: 16,
                                          color: p.isOutOfStock
                                              ? Colors.red.shade800
                                              : p.isLowStock
                                              ? Colors.orange.shade800
                                              : Colors.green.shade800,
                                        ),
                                        label: Text(
                                          '${p.stockQuantity} ${p.unit} (Edit)',
                                          style: TextStyle(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.bold,
                                            color: p.isOutOfStock
                                                ? Colors.red.shade900
                                                : p.isLowStock
                                                    ? Colors.orange.shade900
                                                    : Colors.green.shade900,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Actions: Edit Details / Delete
                                  Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit_outlined,
                                              size: 18),
                                          color: Colors.blue.shade700,
                                          tooltip: 'Edit Details & Tax Price',
                                          onPressed: () =>
                                              _showAddEditProductDialog(
                                                  context, state,
                                                  product: p),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                              Icons.delete_outline_rounded,
                                              size: 18),
                                          color: Colors.red.shade600,
                                          tooltip: 'Delete Product',
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (ctx) => AlertDialog(
                                                title: const Text(
                                                    'Delete Product?'),
                                                content: Text(
                                                    'Are you sure you want to delete "${p.name}"?'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(ctx),
                                                    child:
                                                        const Text('Cancel'),
                                                  ),
                                                  ElevatedButton(
                                                    style:
                                                        ElevatedButton.styleFrom(
                                                      backgroundColor:
                                                          Colors.red,
                                                      foregroundColor:
                                                          Colors.white,
                                                    ),
                                                    onPressed: () {
                                                      state.deleteProduct(p.id);
                                                      Navigator.pop(ctx);
                                                    },
                                                    child:
                                                        const Text('Delete'),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppState state) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                size: 56,
                color: Color(0xFF2563EB),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Products in Store Catalog',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add items under Paint, Electrical, Hardware, or Plumbing to begin billing!',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showAddEditProductDialog(context, state),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.add, size: 20),
              label: const Text(
                'Add Product & Stock',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Dedicated Stock Edit Dialog ---
  void _showStockEditDialog(
      BuildContext context, AppState state, Product product) {
    int adjustmentMode = 0; // 0: Add Stock (+), 1: Direct Count (=)
    final addQtyCtrl = TextEditingController(text: '10');
    final directQtyCtrl =
        TextEditingController(text: product.stockQuantity.toString());
    final newCostCtrl =
        TextEditingController(text: product.costPrice.toStringAsFixed(2));

    final catColor = getCategoryColor(product.category);
    final catIcon = getCategoryIcon(product.category);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) {
          final added = int.tryParse(addQtyCtrl.text) ?? 0;
          final newTotalIfAdded = product.stockQuantity + added;

          return AlertDialog(
            title: Row(
              children: [
                Icon(catIcon, color: catColor),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Manage Stock: ${product.name}',
                    style: const TextStyle(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: 460,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: catColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                product.category,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: catColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Current Stock:',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        Text(
                          '${product.stockQuantity} ${product.unit}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: catColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Mode Toggle
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text('+ Add New Stock')),
                          selected: adjustmentMode == 0,
                          onSelected: (val) =>
                              setDlgState(() => adjustmentMode = 0),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(
                              child: Text('= Set Direct Quantity')),
                          selected: adjustmentMode == 1,
                          onSelected: (val) =>
                              setDlgState(() => adjustmentMode = 1),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (adjustmentMode == 0) ...[
                    TextField(
                      controller: addQtyCtrl,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setDlgState(() {}),
                      decoration: InputDecoration(
                        labelText: 'Quantity to Add (${product.unit}) *',
                        prefixIcon: const Icon(Icons.add_circle_outline),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: newCostCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Purchase Cost per Unit (₹) (Optional)',
                        prefixText: '₹ ',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade300),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'New Total Stock will be:',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '$newTotalIfAdded ${product.unit}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    TextField(
                      controller: directQtyCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'New Direct Stock Count (${product.unit}) *',
                        prefixIcon: const Icon(Icons.edit_note),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  if (adjustmentMode == 0) {
                    final qtyToAdd = int.tryParse(addQtyCtrl.text) ?? 0;
                    final cost = double.tryParse(newCostCtrl.text);
                    if (qtyToAdd > 0) {
                      state.restockProduct(product.id, qtyToAdd,
                          newCostPrice: cost);
                    }
                  } else {
                    final directQty = int.tryParse(directQtyCtrl.text) ?? 0;
                    state.adjustStock(product.id, directQty);
                  }
                  Navigator.pop(ctx);
                },
                child: const Text('Save Stock'),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- Add / Edit Product Dialog with 4 Categories & Live Tax Calculator ---
  void _showAddEditProductDialog(
    BuildContext context,
    AppState state, {
    Product? product,
  }) {
    final isEditing = product != null;
    final nameCtrl = TextEditingController(text: product?.name ?? '');
    final brandCtrl = TextEditingController(text: product?.brand ?? '');
    String selectedCategory = product?.category ?? 'Paint';

    String generateDefaultProductCode(String category) {
      String prefix;
      switch (category.toLowerCase()) {
        case 'paint':
          prefix = 'PNT';
          break;
        case 'electrical':
          prefix = 'ELE';
          break;
        case 'hardware':
          prefix = 'HDW';
          break;
        case 'plumbing':
          prefix = 'PLM';
          break;
        default:
          prefix = 'PRD';
      }
      final count = state.products
              .where((p) => p.category.toLowerCase() == category.toLowerCase())
              .length +
          1;
      return '$prefix-${count.toString().padLeft(3, '0')}';
    }

    final productCodeCtrl = TextEditingController(
        text: product?.barcode ?? generateDefaultProductCode(selectedCategory));
    final hsnCtrl = TextEditingController(
        text: product?.hsnCode ?? (selectedCategory == 'Paint' ? '320890' : '853690'));
    final costCtrl =
        TextEditingController(text: product?.costPrice.toString() ?? '');
    final sellingCtrl =
        TextEditingController(text: product?.sellingPrice.toString() ?? '');
    final stockCtrl =
        TextEditingController(text: product?.stockQuantity.toString() ?? '10');
    final lowStockCtrl = TextEditingController(
        text: product?.lowStockThreshold.toString() ?? '3');
    final warrantyCtrl =
        TextEditingController(text: product?.warranty ?? 'Standard Warranty');
    final unitCtrl = TextEditingController(
        text: product?.unit ?? (selectedCategory == 'Paint' ? 'Litre' : 'Pcs'));

    double gstRate = product?.gstRate ?? 18.0;
    bool isPriceTaxInclusive = true; // MRP vs Base Rate
    bool reqSerial = product?.requiresSerialNumber ?? false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) {
          // Live Tax Computation from Entered Price
          final enteredSellingPrice =
              double.tryParse(sellingCtrl.text.trim()) ?? 0.0;
          final enteredCostPrice =
              double.tryParse(costCtrl.text.trim()) ?? 0.0;

          double baseSellingPrice;
          double taxSellingAmount;
          double finalSellingPrice;

          if (isPriceTaxInclusive) {
            // Price entered includes tax (e.g. MRP ₹1180 with 18% GST => Base ₹1000, Tax ₹180)
            finalSellingPrice = enteredSellingPrice;
            baseSellingPrice = gstRate > 0
                ? finalSellingPrice / (1.0 + (gstRate / 100.0))
                : finalSellingPrice;
            taxSellingAmount = finalSellingPrice - baseSellingPrice;
          } else {
            // Price entered excludes tax (e.g. Base ₹1000 + 18% GST => Tax ₹180, Total ₹1180)
            baseSellingPrice = enteredSellingPrice;
            taxSellingAmount = baseSellingPrice * (gstRate / 100.0);
            finalSellingPrice = baseSellingPrice + taxSellingAmount;
          }

          final cgstAmount = taxSellingAmount / 2;
          final sgstAmount = taxSellingAmount / 2;

          return AlertDialog(
            title: Text(isEditing ? 'Edit Product' : 'Add New Product & Stock'),
            content: SizedBox(
              width: 680,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- 4 Primary Categories Selector ---
                    const Text(
                      'Select Product Category *',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: primaryCategories.map((cat) {
                        final isSel = selectedCategory == cat;
                        final color = getCategoryColor(cat);
                        final icon = getCategoryIcon(cat);

                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: InkWell(
                              onTap: () {
                                setDlgState(() {
                                  selectedCategory = cat;
                                  // Update suggested product code if not customized
                                  if (!isEditing) {
                                    final cur = productCodeCtrl.text.trim();
                                    if (cur.isEmpty ||
                                        cur.startsWith('PNT-') ||
                                        cur.startsWith('ELE-') ||
                                        cur.startsWith('HDW-') ||
                                        cur.startsWith('PLM-') ||
                                        cur.startsWith('PRD-')) {
                                      productCodeCtrl.text =
                                          generateDefaultProductCode(cat);
                                    }
                                  }
                                  // Update sensible HSN and Unit defaults if empty
                                  if (cat == 'Paint') {
                                    if (hsnCtrl.text.isEmpty || hsnCtrl.text.startsWith('85') || hsnCtrl.text.startsWith('73') || hsnCtrl.text.startsWith('39')) {
                                      hsnCtrl.text = '320890';
                                    }
                                    if (unitCtrl.text == 'Pcs' || unitCtrl.text.isEmpty) {
                                      unitCtrl.text = 'Litre';
                                    }
                                  } else if (cat == 'Electrical') {
                                    if (hsnCtrl.text.isEmpty || hsnCtrl.text.startsWith('32') || hsnCtrl.text.startsWith('73') || hsnCtrl.text.startsWith('39')) {
                                      hsnCtrl.text = '853690';
                                    }
                                    if (unitCtrl.text == 'Litre' || unitCtrl.text.isEmpty) {
                                      unitCtrl.text = 'Pcs';
                                    }
                                  } else if (cat == 'Hardware') {
                                    if (hsnCtrl.text.isEmpty || hsnCtrl.text.startsWith('32') || hsnCtrl.text.startsWith('85') || hsnCtrl.text.startsWith('39')) {
                                      hsnCtrl.text = '731815';
                                    }
                                    if (unitCtrl.text == 'Litre' || unitCtrl.text.isEmpty) {
                                      unitCtrl.text = 'Pcs';
                                    }
                                  } else if (cat == 'Plumbing') {
                                    if (hsnCtrl.text.isEmpty || hsnCtrl.text.startsWith('32') || hsnCtrl.text.startsWith('85') || hsnCtrl.text.startsWith('73')) {
                                      hsnCtrl.text = '391723';
                                    }
                                    if (unitCtrl.text == 'Litre' || unitCtrl.text.isEmpty) {
                                      unitCtrl.text = 'Pcs';
                                    }
                                  }
                                });
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: isSel
                                      ? color.withValues(alpha: 0.15)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSel ? color : Colors.grey.shade300,
                                    width: isSel ? 2 : 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(icon,
                                        size: 18,
                                        color: isSel
                                            ? color
                                            : Colors.grey.shade600),
                                    const SizedBox(width: 6),
                                    Text(
                                      cat,
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: isSel
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                        color: isSel
                                            ? color
                                            : Colors.grey.shade800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Row 1: Name & Brand
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: nameCtrl,
                            decoration: InputDecoration(
                              labelText: 'Product Name *',
                              hintText: selectedCategory == 'Paint'
                                  ? 'e.g. Apex Weatherproof Emulsion 4L'
                                  : selectedCategory == 'Electrical'
                                      ? 'e.g. 1.5 sq mm Copper Wire 90m'
                                      : selectedCategory == 'Plumbing'
                                          ? 'e.g. 1 inch CPVC Pipe (3m)'
                                          : 'e.g. Stainless Steel Door Hinges 4 inch',
                              border: const OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: brandCtrl,
                            decoration: InputDecoration(
                              labelText: 'Brand / Make *',
                              hintText: selectedCategory == 'Paint'
                                  ? 'Asian Paints, Nerolac, Berger'
                                  : selectedCategory == 'Electrical'
                                      ? 'Havells, Polycab, Anchor'
                                      : selectedCategory == 'Plumbing'
                                          ? 'Astral, Supreme, Ashirvad'
                                          : 'Godrej, Tata, Generic',
                              border: const OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Row 2: Product Code & HSN
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: productCodeCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Product Code *',
                              hintText: 'e.g. PNT-001, ELE-102, HDW-05',
                              prefixIcon: Icon(Icons.tag_rounded, size: 18),
                              border: OutlineInputBorder(),
                              isDense: true,
                              helperText: 'Unique shop item/product code',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: hsnCtrl,
                            decoration: const InputDecoration(
                              labelText: 'HSN/SAC Code',
                              hintText: 'e.g. 3208, 8536, 7318, 3917',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // --- TAX & PRICING CONFIGURATION SECTION ---
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'PRICE & GST TAX CALCULATION',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E3A8A),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    isPriceTaxInclusive
                                        ? 'Entered Price Includes Tax (MRP)'
                                        : 'Entered Price Excludes Tax (Base + Tax)',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue.shade900,
                                    ),
                                  ),
                                  Transform.scale(
                                    scale: 0.75,
                                    child: Switch(
                                      value: isPriceTaxInclusive,
                                      onChanged: (val) {
                                        setDlgState(
                                            () => isPriceTaxInclusive = val);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          Row(
                            children: [
                              // Purchase Cost
                              Expanded(
                                child: TextField(
                                  controller: costCtrl,
                                  keyboardType: TextInputType.number,
                                  onChanged: (_) => setDlgState(() {}),
                                  decoration: const InputDecoration(
                                    labelText: 'Purchase Cost (₹) *',
                                    prefixText: '₹ ',
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                    fillColor: Colors.white,
                                    filled: true,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Selling Price
                              Expanded(
                                child: TextField(
                                  controller: sellingCtrl,
                                  keyboardType: TextInputType.number,
                                  onChanged: (_) => setDlgState(() {}),
                                  decoration: InputDecoration(
                                    labelText: isPriceTaxInclusive
                                        ? 'Selling Price / MRP (₹) *'
                                        : 'Base Price (Excl. Tax) (₹) *',
                                    prefixText: '₹ ',
                                    border: const OutlineInputBorder(),
                                    isDense: true,
                                    fillColor: Colors.white,
                                    filled: true,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),

                              // GST Slab Dropdown
                              Expanded(
                                child: DropdownButtonFormField<double>(
                                  initialValue: gstRate,
                                  isDense: true,
                                  decoration: const InputDecoration(
                                    labelText: 'GST Tax Rate',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 10),
                                    fillColor: Colors.white,
                                    filled: true,
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                        value: 0.0, child: Text('0% GST (Nil)')),
                                    DropdownMenuItem(
                                        value: 5.0, child: Text('5% GST')),
                                    DropdownMenuItem(
                                        value: 12.0, child: Text('12% GST')),
                                    DropdownMenuItem(
                                        value: 18.0, child: Text('18% GST')),
                                    DropdownMenuItem(
                                        value: 28.0, child: Text('28% GST')),
                                  ],
                                  onChanged: (val) {
                                    if (val != null) {
                                      setDlgState(() => gstRate = val);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Real-Time Tax Breakdown Box
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.blue.shade100),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Taxable Base Rate:',
                                      style: TextStyle(
                                          fontSize: 11.5,
                                          color: Colors.grey.shade700),
                                    ),
                                    Text(
                                      '₹ ${baseSellingPrice.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'GST (${gstRate.toInt()}%):',
                                      style: TextStyle(
                                          fontSize: 11.5,
                                          color: Colors.grey.shade700),
                                    ),
                                    Text(
                                      '₹ ${taxSellingAmount.toStringAsFixed(2)} (CGST: ₹${cgstAmount.toStringAsFixed(2)} + SGST: ₹${sgstAmount.toStringAsFixed(2)})',
                                      style: const TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF2563EB)),
                                    ),
                                  ],
                                ),
                                const Divider(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Final Customer Billing Price (MRP):',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      '₹ ${finalSellingPrice.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF10B981),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Row 4: Stock Qty, Low stock threshold, Unit
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: stockCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Initial Stock Qty *',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: lowStockCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Low Stock Alert Level',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: unitCtrl,
                            decoration: InputDecoration(
                              labelText: 'Unit *',
                              hintText: selectedCategory == 'Paint'
                                  ? 'Litre, Can, Kg, Tin'
                                  : selectedCategory == 'Electrical'
                                      ? 'Pcs, Meter, Roll, Coil'
                                      : selectedCategory == 'Plumbing'
                                          ? 'Pcs, Meter, Length, Set'
                                          : 'Pcs, Box, Kg, Dozen',
                              border: const OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Row 5: Warranty & Serial Tracking
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: warrantyCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Warranty / Guarantee Details',
                              hintText: 'e.g. 5 Years Company Warranty, None',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    CheckboxListTile(
                      title: const Text(
                        'Requires Serial Number / Batch tracking during Billing',
                        style: TextStyle(fontSize: 12.5),
                      ),
                      subtitle: const Text(
                        'Enable if you track serial numbers for electrical motors, power tools, or batch codes',
                        style: TextStyle(fontSize: 11),
                      ),
                      value: reqSerial,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) {
                        setDlgState(() => reqSerial = val ?? false);
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  if (nameCtrl.text.trim().isEmpty) return;

                  final p = Product(
                    id: isEditing ? product.id : _uuid.v4(),
                    name: nameCtrl.text.trim(),
                    brand: brandCtrl.text.trim().isEmpty
                        ? 'Generic'
                        : brandCtrl.text.trim(),
                    category: selectedCategory,
                    barcode: productCodeCtrl.text.trim().isEmpty
                        ? generateDefaultProductCode(selectedCategory)
                        : productCodeCtrl.text.trim(),
                    hsnCode: hsnCtrl.text.trim().isEmpty
                        ? '853690'
                        : hsnCtrl.text.trim(),
                    costPrice: enteredCostPrice,
                    sellingPrice: finalSellingPrice,
                    gstRate: gstRate,
                    stockQuantity: int.tryParse(stockCtrl.text) ?? 0,
                    lowStockThreshold: int.tryParse(lowStockCtrl.text) ?? 3,
                    unit: unitCtrl.text.trim().isEmpty
                        ? (selectedCategory == 'Paint' ? 'Litre' : 'Pcs')
                        : unitCtrl.text.trim(),
                    warranty: warrantyCtrl.text.trim(),
                    requiresSerialNumber: reqSerial,
                  );

                  if (isEditing) {
                    state.updateProduct(p);
                  } else {
                    state.addProduct(p);
                  }
                  Navigator.pop(ctx);
                },
                child: Text(isEditing ? 'Update Product' : 'Add to Inventory'),
              ),
            ],
          );
        },
      ),
    );
  }

  static Widget _buildTh(String text, {TextAlign align = TextAlign.left}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Text(
        text,
        textAlign: align,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  static Widget _buildTd(
    String text, {
    bool isBold = false,
    Color? color,
    TextAlign align = TextAlign.left,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Text(
        text,
        textAlign: align,
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          color: color ?? const Color(0xFF1E293B),
        ),
      ),
    );
  }
}
