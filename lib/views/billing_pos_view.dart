import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../models/invoice.dart';
import '../providers/app_state.dart';
import '../widgets/header_bar.dart';
import '../widgets/invoice_dialog.dart';

class BillingPosView extends StatefulWidget {
  const BillingPosView({super.key});

  @override
  State<BillingPosView> createState() => _BillingPosViewState();
}

class _BillingPosViewState extends State<BillingPosView> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  String _selectedCategory = 'All';
  String _searchQuery = '';

  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'paint':
        return const Color(0xFF9333EA);
      case 'electrical':
        return const Color(0xFFD97706);
      case 'hardware':
        return const Color(0xFF2563EB);
      case 'plumbing':
        return const Color(0xFF0D9488);
      default:
        return const Color(0xFF475569);
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
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final currency = NumberFormat('#,##,##0.00');

    // Filter products
    final filteredProducts = state.products.where((p) {
      final matchesCategory =
          _selectedCategory == 'All' || p.category == _selectedCategory;
      final query = _searchQuery.toLowerCase();
      final matchesQuery = query.isEmpty ||
          p.name.toLowerCase().contains(query) ||
          p.barcode.toLowerCase().contains(query) ||
          p.brand.toLowerCase().contains(query) ||
          p.hsnCode.toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList();

    final categories = ['All', ...state.categories];

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Column(
        children: [
          HeaderBar(
            title: 'Point of Sale (POS) & GST Billing',
            subtitle:
                'Invoice: ${state.settings.invoicePrefix}${state.settings.nextInvoiceNumber}',
            actions: [
              if (state.cart.isNotEmpty)
                OutlinedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Clear Cart?'),
                        content: const Text(
                            'Are you sure you want to clear the current bill?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              state.clearCart();
                              Navigator.pop(ctx);
                            },
                            child: const Text('Clear'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.delete_sweep_rounded, size: 18),
                  label: const Text('Clear Bill'),
                ),
            ],
          ),

          // Main 2-Column POS Layout
          Expanded(
            child: Row(
              children: [
                // Left: Product Catalog & Quick Add (60%)
                Expanded(
                  flex: 6,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Search bar & Category Bar
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                focusNode: _searchFocus,
                                onChanged: (val) {
                                  setState(() {
                                    _searchQuery = val;
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText:
                                      'Scan Barcode or Search by Name, Brand, SKU (F1)...',
                                  prefixIcon: const Icon(Icons.search_rounded),
                                  suffixIcon: _searchQuery.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(Icons.clear),
                                          onPressed: () {
                                            _searchController.clear();
                                            setState(() {
                                              _searchQuery = '';
                                            });
                                          },
                                        )
                                      : null,
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade300),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade300),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Category Chips with Icons
                        SizedBox(
                          height: 38,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: categories.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(width: 8),
                            itemBuilder: (context, idx) {
                              final cat = categories[idx];
                              final isSelected = _selectedCategory == cat;
                              final catColor = getCategoryColor(cat);
                              final catIcon = getCategoryIcon(cat);

                              return FilterChip(
                                avatar: cat != 'All'
                                    ? Icon(catIcon,
                                        size: 14,
                                        color: isSelected
                                            ? Colors.white
                                            : catColor)
                                    : null,
                                label: Text(cat),
                                selected: isSelected,
                                onSelected: (sel) {
                                  setState(() {
                                    _selectedCategory = cat;
                                  });
                                },
                                selectedColor: cat == 'All'
                                    ? const Color(0xFF2563EB)
                                    : catColor,
                                labelStyle: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.grey.shade800,
                                ),
                                backgroundColor: Colors.white,
                                showCheckmark: false,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(
                                    color: isSelected
                                        ? (cat == 'All'
                                            ? const Color(0xFF2563EB)
                                            : catColor)
                                        : Colors.grey.shade300,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Products Grid
                        Expanded(
                          child: filteredProducts.isEmpty
                              ? Center(
                                  child: state.products.isEmpty
                                      ? Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.inventory_2_outlined,
                                                size: 56,
                                                color: Colors.grey.shade400),
                                            const SizedBox(height: 14),
                                            const Text(
                                              'No products in catalog yet',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF0F172A),
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              'Add items under Paint, Electrical, Hardware, or Plumbing to start billing.',
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.grey.shade600),
                                            ),
                                            const SizedBox(height: 16),
                                            ElevatedButton.icon(
                                              onPressed: () =>
                                                  state.setViewIndex(2),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    const Color(0xFF2563EB),
                                                foregroundColor: Colors.white,
                                              ),
                                              icon: const Icon(Icons.add,
                                                  size: 18),
                                              label: const Text(
                                                  'Add Products in Inventory'),
                                            ),
                                          ],
                                        )
                                      : Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.search_off_rounded,
                                                size: 48,
                                                color: Colors.grey.shade400),
                                            const SizedBox(height: 12),
                                            Text(
                                              'No products found matching "$_searchQuery"',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                )
                              : GridView.builder(
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    childAspectRatio: 1.25,
                                    crossAxisSpacing: 14,
                                    mainAxisSpacing: 14,
                                  ),
                                  itemCount: filteredProducts.length,
                                  itemBuilder: (context, idx) {
                                    final p = filteredProducts[idx];
                                    final isOutOfStock = p.stockQuantity <= 0;

                                    return _buildProductCard(
                                        context, p, isOutOfStock, state);
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Right: Active Bill / Cart (40%)
                Container(
                  width: 440,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      left:
                          BorderSide(color: Colors.grey.shade200, width: 1.5),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(-2, 0),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Customer Banner & Settings
                      _buildCustomerSection(context, state),
                      const Divider(height: 1),

                      // Cart Items Header
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        color: const Color(0xFFF8FAFC),
                        child: Row(
                          children: [
                            Text(
                              'CART ITEMS (${state.cart.length})',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const Spacer(),
                            // Inter-state toggle (IGST vs CGST/SGST)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  state.cartIsInterState
                                      ? 'Inter-State (IGST)'
                                      : 'Intra-State (CGST+SGST)',
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Transform.scale(
                                  scale: 0.7,
                                  child: Switch(
                                    value: state.cartIsInterState,
                                    onChanged: (val) =>
                                        state.setCartInterState(val),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Cart Items List
                      Expanded(
                        child: state.cart.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.shopping_cart_outlined,
                                      size: 52,
                                      color: Colors.grey.shade300,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Bill is empty',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Click any product or scan barcode to add',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.all(12),
                                itemCount: state.cart.length,
                                separatorBuilder: (context, index) =>
                                    const Divider(height: 16),
                                itemBuilder: (context, idx) {
                                  final item = state.cart[idx];
                                  final lineTotal = state.cartIsInterState
                                      ? item.totalAmountInter
                                      : item.totalAmountIntra;

                                  return _buildCartItemTile(
                                      context, state, item, idx, lineTotal);
                                },
                              ),
                      ),

                      // Bill Summary & Checkout
                      _buildCheckoutSection(context, state, currency),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    Product p,
    bool isOutOfStock,
    AppState state,
  ) {
    final int inCartQty = state.getCartQuantityForProduct(p.id);
    final int availableLeft =
        (p.stockQuantity - inCartQty).clamp(0, p.stockQuantity);
    final bool isMaxInCart = inCartQty >= p.stockQuantity && !isOutOfStock;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isOutOfStock
              ? Colors.red.shade200
              : isMaxInCart
                  ? Colors.orange.shade300
                  : p.isLowStock
                      ? Colors.orange.shade200
                      : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isOutOfStock
              ? () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${p.name} is currently out of stock!'),
                      backgroundColor: Colors.red.shade700,
                    ),
                  );
                }
              : isMaxInCart
                  ? () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Cannot add more! All ${p.stockQuantity} ${p.unit} of "${p.name}" are already in this bill.'),
                          backgroundColor: Colors.orange.shade800,
                        ),
                      );
                    }
                  : () {
                      final ok = state.addToCart(p);
                      if (!ok) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Reached stock limit for ${p.name}!'),
                            backgroundColor: Colors.orange.shade800,
                          ),
                        );
                      }
                    },
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: getCategoryColor(p.category)
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            getCategoryIcon(p.category),
                            size: 11,
                            color: getCategoryColor(p.category),
                          ),
                          const SizedBox(width: 3.5),
                          Text(
                            p.category,
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              color: getCategoryColor(p.category),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isOutOfStock
                            ? Colors.red.shade50
                            : isMaxInCart
                                ? Colors.orange.shade50
                                : Colors.green.shade50,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: isOutOfStock
                              ? Colors.red.shade200
                              : isMaxInCart
                                  ? Colors.orange.shade300
                                  : Colors.green.shade200,
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        isOutOfStock
                            ? 'Out of Stock (0)'
                            : isMaxInCart
                                ? 'All in Bill ($inCartQty/${p.stockQuantity})'
                                : inCartQty > 0
                                    ? '$availableLeft left in store'
                                    : '${p.stockQuantity} ${p.unit} available',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: isOutOfStock
                              ? Colors.red.shade700
                              : isMaxInCart
                                  ? Colors.orange.shade800
                                  : Colors.green.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  p.name,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${p.brand} • HSN: ${p.hsnCode}',
                  style: TextStyle(fontSize: 10.5, color: Colors.grey.shade500),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '₹ ${p.sellingPrice.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                        Text(
                          'incl. ${p.gstRate.toInt()}% GST',
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isOutOfStock || isMaxInCart
                            ? Colors.grey.shade200
                            : const Color(0xFF2563EB),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.add,
                        size: 16,
                        color: isOutOfStock || isMaxInCart
                            ? Colors.grey
                            : Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerSection(BuildContext context, AppState state) {
    return Container(
      padding: const EdgeInsets.all(14),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person_outline_rounded,
                  size: 18, color: Color(0xFF2563EB)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  state.customerName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton.icon(
                onPressed: () => _showCustomerSelectDialog(context, state),
                icon: const Icon(Icons.swap_horiz_rounded, size: 16),
                label: const Text('Change Customer',
                    style: TextStyle(fontSize: 11)),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
          if (state.customerPhone.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              'Phone: ${state.customerPhone} ${state.customerGstin.isNotEmpty ? "• GSTIN: ${state.customerGstin}" : ""}',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCartItemTile(
    BuildContext context,
    AppState state,
    InvoiceItem item,
    int idx,
    double lineTotal,
  ) {
    final pList = state.products.where((p) => p.id == item.productId);
    final int totalStock =
        pList.isNotEmpty ? pList.first.stockQuantity : item.quantity;
    final int remainingAfter =
        (totalStock - item.quantity).clamp(0, totalStock);
    final bool reachedMax = item.quantity >= totalStock;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'HSN: ${item.hsnCode} • GST: ${item.gstRate.toInt()}% • Stock: $totalStock ($remainingAfter left)',
                    style: TextStyle(
                      fontSize: 10.5,
                      color: remainingAfter == 0
                          ? Colors.orange.shade800
                          : Colors.grey.shade600,
                      fontWeight: remainingAfter == 0
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.close_rounded,
                  size: 16, color: Colors.grey.shade400),
              onPressed: () => state.removeFromCart(idx),
              tooltip: 'Remove',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Controls row: Qty Stepper, Discount, and Total
        Row(
          children: [
            // Stepper
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () =>
                        state.updateCartQuantity(idx, item.quantity - 1),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Icon(Icons.remove, size: 14),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      '${item.quantity}',
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                  InkWell(
                    onTap: reachedMax
                        ? () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Cannot add more! Only $totalStock ${item.unit} available in stock for "${item.productName}".'),
                                backgroundColor: Colors.orange.shade800,
                              ),
                            );
                          }
                        : () =>
                            state.updateCartQuantity(idx, item.quantity + 1),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: Icon(
                        Icons.add,
                        size: 14,
                        color: reachedMax ? Colors.grey.shade400 : Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // S/N / IMEI button
            InkWell(
              onTap: () => _showSerialInputDialog(context, state, item, idx),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: item.serialNumbers.isNotEmpty
                      ? Colors.teal.shade50
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: item.serialNumbers.isNotEmpty
                        ? Colors.teal.shade300
                        : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.qr_code_scanner_rounded,
                      size: 12,
                      color: item.serialNumbers.isNotEmpty
                          ? Colors.teal.shade700
                          : Colors.grey.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item.serialNumbers.isNotEmpty
                          ? '${item.serialNumbers.length} IMEI/SN'
                          : '+ IMEI/SN',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: item.serialNumbers.isNotEmpty
                            ? Colors.teal.shade800
                            : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),

            // Line Total
            Text(
              '₹ ${lineTotal.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCheckoutSection(
    BuildContext context,
    AppState state,
    NumberFormat currency,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        children: [
          // Subtotal
          _buildSummaryLine('Taxable Subtotal:',
              '₹ ${currency.format(state.cartSubtotal)}'),
          if (!state.cartIsInterState) ...[
            _buildSummaryLine(
                'CGST (Central):', '₹ ${currency.format(state.cartCgst)}'),
            _buildSummaryLine(
                'SGST (State):', '₹ ${currency.format(state.cartSgst)}'),
          ] else ...[
            _buildSummaryLine(
                'IGST (Integrated):', '₹ ${currency.format(state.cartIgst)}'),
          ],
          if (state.cartRoundOff != 0)
            _buildSummaryLine(
                'Round Off:', '₹ ${currency.format(state.cartRoundOff)}'),

          const Divider(height: 14),

          // Grand Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Grand Total (₹):',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              Text(
                '₹ ${currency.format(state.cartGrandTotal)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2563EB),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Payment mode options
          Row(
            children: [
              _buildPaymentChip('Cash', state),
              const SizedBox(width: 6),
              _buildPaymentChip('UPI', state),
              const SizedBox(width: 6),
              _buildPaymentChip('Card', state),
              const SizedBox(width: 6),
              _buildPaymentChip('Due', state),
            ],
          ),
          const SizedBox(height: 14),

          // Checkout CTA button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: state.cart.isEmpty
                  ? null
                  : () => _handleCheckout(context, state),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 2,
              ),
              icon: const Icon(Icons.print_rounded, size: 20),
              label: Text(
                'PRINT TAX INVOICE (₹ ${currency.format(state.cartGrandTotal)})',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryLine(String title, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600)),
          Text(val,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B))),
        ],
      ),
    );
  }

  Widget _buildPaymentChip(String mode, AppState state) {
    final isSelected = state.paymentMode == mode;
    return Expanded(
      child: InkWell(
        onTap: () => state.setPaymentMode(mode),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF1E293B)
                  : Colors.grey.shade300,
            ),
          ),
          child: Center(
            child: Text(
              mode,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.grey.shade800,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleCheckout(BuildContext ctx, AppState state) async {
    final grandTotal = state.cartGrandTotal;
    final isDuePayment = state.paymentMode == 'Due';

    final invoice = await state.completeSale(
      amountPaid: isDuePayment ? 0.0 : grandTotal,
    );

    if (invoice != null && mounted) {
      // Show full A4 invoice preview & print dialog
      await InvoiceDialog.show(
        context,
        invoice: invoice,
        settings: state.settings,
      );
    }
  }

  void _showCustomerSelectDialog(BuildContext context, AppState state) {
    final nameCtrl = TextEditingController(text: state.customerName);
    final phoneCtrl = TextEditingController(text: state.customerPhone);
    final gstinCtrl = TextEditingController(text: state.customerGstin);
    final addressCtrl = TextEditingController(text: state.customerAddress);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Customer Details for Invoice'),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quick Select existing customer
                const Text('Select Existing Customer:',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.customers.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, idx) {
                      final c = state.customers[idx];
                      return ListTile(
                        dense: true,
                        title: Text(c.name,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(
                            'Phone: ${c.phone} ${c.dueBalance > 0 ? "• Due: ₹${c.dueBalance.toStringAsFixed(0)}" : ""}'),
                        onTap: () {
                          state.selectCustomer(c);
                          Navigator.pop(ctx);
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 18),
                const Text('Or Enter New Customer Details:',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Customer / Business Name',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: phoneCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Mobile Number',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: gstinCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Customer GSTIN (Optional for B2B)',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: addressCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Billing Address (Optional)',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              state.selectCustomer(null);
              Navigator.pop(ctx);
            },
            child: const Text('Reset to Walk-in'),
          ),
          ElevatedButton(
            onPressed: () {
              state.updateCustomerDetails(
                name: nameCtrl.text,
                phone: phoneCtrl.text,
                gstin: gstinCtrl.text,
                address: addressCtrl.text,
              );
              Navigator.pop(ctx);
            },
            child: const Text('Save Customer'),
          ),
        ],
      ),
    );
  }

  void _showSerialInputDialog(
    BuildContext context,
    AppState state,
    InvoiceItem item,
    int itemIdx,
  ) {
    final ctrl =
        TextEditingController(text: item.serialNumbers.join('\n'));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('IMEI / Serial Numbers: ${item.productName}'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter one IMEI or Serial Number per line (Qty: ${item.quantity}):',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: ctrl,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'e.g.\nIMEI 1: 354890123456789\nIMEI 2: 354890123456780',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final lines = ctrl.text
                  .split('\n')
                  .map((s) => s.trim())
                  .where((s) => s.isNotEmpty)
                  .toList();
              state.updateCartItemSerials(itemIdx, lines);
              Navigator.pop(ctx);
            },
            child: const Text('Save Serials'),
          ),
        ],
      ),
    );
  }
}
