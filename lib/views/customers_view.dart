import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/customer.dart';
import '../providers/app_state.dart';
import '../widgets/header_bar.dart';
import '../widgets/stat_card.dart';

class CustomersView extends StatefulWidget {
  const CustomersView({super.key});

  @override
  State<CustomersView> createState() => _CustomersViewState();
}

class _CustomersViewState extends State<CustomersView> {
  final TextEditingController _searchController = TextEditingController();
  final Uuid _uuid = const Uuid();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final currency = NumberFormat('#,##,##0.00');

    final filtered = state.customers.where((c) {
      final q = _searchController.text.toLowerCase();
      return q.isEmpty ||
          c.name.toLowerCase().contains(q) ||
          c.phone.toLowerCase().contains(q) ||
          (c.gstin != null && c.gstin!.toLowerCase().contains(q));
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Column(
        children: [
          HeaderBar(
            title: 'Customer Directory & Khata Ledger',
            subtitle:
                'Manage customer contacts, B2B GSTIN profiles and credit balance dues',
            actions: [
              ElevatedButton.icon(
                onPressed: () => _showAddEditCustomerDialog(context, state),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.person_add_rounded, size: 18),
                label: const Text('Add Customer'),
              ),
            ],
          ),

          // Overview Stats
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                StatCard(
                  title: 'Total Customers',
                  value: '${state.customers.length}',
                  subtitle: 'Registered buyers & accounts',
                  icon: Icons.people_alt_rounded,
                  color: const Color(0xFF2563EB),
                ),
                const SizedBox(width: 16),
                StatCard(
                  title: 'Total Credit Dues (Khata)',
                  value: '₹ ${currency.format(state.totalCustomerDues)}',
                  subtitle: 'Pending receivables',
                  icon: Icons.receipt_long_rounded,
                  color: const Color(0xFFEF4444),
                ),
                const SizedBox(width: 16),
                StatCard(
                  title: 'Total Customer Business',
                  value:
                      '₹ ${currency.format(state.customers.fold(0.0, (sum, c) => sum + c.totalPurchases))}',
                  subtitle: 'Lifetime sales volume',
                  icon: Icons.account_balance_wallet_rounded,
                  color: const Color(0xFF10B981),
                ),
              ],
            ),
          ),

          // Search Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search by Customer Name, Phone, or GSTIN...',
                prefixIcon: const Icon(Icons.search, size: 20),
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
          ),
          const Divider(height: 1),

          // Customers Table
          Expanded(
            child: SingleChildScrollView(
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
                      horizontalInside:
                          BorderSide(color: Colors.grey.shade200, width: 1),
                    ),
                    columnWidths: const {
                      0: FlexColumnWidth(2.5), // Name
                      1: FlexColumnWidth(1.6), // Phone
                      2: FlexColumnWidth(2.0), // GSTIN
                      3: FlexColumnWidth(2.5), // Address
                      4: FlexColumnWidth(1.6), // Total Purchases
                      5: FlexColumnWidth(1.6), // Due Balance
                      6: FlexColumnWidth(1.8), // Actions
                    },
                    children: [
                      TableRow(
                        decoration:
                            BoxDecoration(color: Colors.grey.shade100),
                        children: [
                          _buildTh('Customer / Business Name'),
                          _buildTh('Mobile Number'),
                          _buildTh('GSTIN (B2B)'),
                          _buildTh('Billing Address'),
                          _buildTh('Total Purchases'),
                          _buildTh('Khata Due'),
                          _buildTh('Actions', align: TextAlign.center),
                        ],
                      ),
                      ...filtered.map((c) {
                        final hasDue = c.dueBalance > 0;
                        return TableRow(
                          children: [
                            _buildTd(c.name, isBold: true),
                            _buildTd(c.phone),
                            _buildTd(c.gstin ?? '-',
                                color: Colors.blueGrey.shade800),
                            _buildTd(c.address ?? '-',
                                color: Colors.grey.shade700),
                            _buildTd('₹ ${currency.format(c.totalPurchases)}'),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: hasDue
                                        ? Colors.red.shade50
                                        : Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: hasDue
                                          ? Colors.red.shade300
                                          : Colors.green.shade300,
                                    ),
                                  ),
                                  child: Text(
                                    hasDue
                                        ? '₹ ${currency.format(c.dueBalance)} Due'
                                        : 'Clear',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: hasDue
                                          ? Colors.red.shade800
                                          : Colors.green.shade800,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (hasDue)
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF10B981),
                                        foregroundColor: Colors.white,
                                        visualDensity: VisualDensity.compact,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 6),
                                        textStyle: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      onPressed: () =>
                                          _showSettleDueDialog(context, state, c),
                                      child: const Text('Settle Due'),
                                    ),
                                  const SizedBox(width: 6),
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined,
                                        size: 18),
                                    color: Colors.blue.shade700,
                                    tooltip: 'Edit Customer',
                                    onPressed: () =>
                                        _showAddEditCustomerDialog(
                                            context, state,
                                            customer: c),
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

  void _showSettleDueDialog(
      BuildContext context, AppState state, Customer customer) {
    final amountCtrl =
        TextEditingController(text: customer.dueBalance.toStringAsFixed(2));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Settle Khata Due: ${customer.name}'),
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current Outstanding Due: ₹ ${customer.dueBalance.toStringAsFixed(2)}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.red),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount Received (₹)',
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
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final paid = double.tryParse(amountCtrl.text);
              if (paid != null && paid > 0) {
                state.settleCustomerDue(customer.id, paid);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Record Payment'),
          ),
        ],
      ),
    );
  }

  void _showAddEditCustomerDialog(
    BuildContext context,
    AppState state, {
    Customer? customer,
  }) {
    final isEditing = customer != null;
    final nameCtrl = TextEditingController(text: customer?.name ?? '');
    final phoneCtrl = TextEditingController(text: customer?.phone ?? '');
    final gstinCtrl = TextEditingController(text: customer?.gstin ?? '');
    final addressCtrl = TextEditingController(text: customer?.address ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEditing ? 'Edit Customer' : 'Add New Customer'),
        content: SizedBox(
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Customer / Business Name *',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Mobile Number *',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: gstinCtrl,
                decoration: const InputDecoration(
                  labelText: 'GSTIN (Optional for B2B)',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Billing Address (Optional)',
                  border: OutlineInputBorder(),
                  isDense: true,
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
              if (nameCtrl.text.trim().isEmpty) return;

              final c = Customer(
                id: isEditing ? customer.id : _uuid.v4(),
                name: nameCtrl.text.trim(),
                phone: phoneCtrl.text.trim(),
                gstin: gstinCtrl.text.trim().isEmpty
                    ? null
                    : gstinCtrl.text.trim(),
                address: addressCtrl.text.trim().isEmpty
                    ? null
                    : addressCtrl.text.trim(),
                totalPurchases: customer?.totalPurchases ?? 0.0,
                dueBalance: customer?.dueBalance ?? 0.0,
              );

              if (isEditing) {
                state.updateCustomer(c);
              } else {
                state.addCustomer(c);
              }
              Navigator.pop(ctx);
            },
            child: Text(isEditing ? 'Save Changes' : 'Add Customer'),
          ),
        ],
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
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          color: color ?? const Color(0xFF1E293B),
        ),
      ),
    );
  }
}

