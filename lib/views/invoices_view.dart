import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../widgets/header_bar.dart';
import '../widgets/invoice_dialog.dart';

class InvoicesView extends StatefulWidget {
  const InvoicesView({super.key});

  @override
  State<InvoicesView> createState() => _InvoicesViewState();
}

class _InvoicesViewState extends State<InvoicesView> {
  final TextEditingController _searchController = TextEditingController();
  String _statusFilter = 'All'; // All, Paid, Due

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final currency = NumberFormat('#,##,##0.00');
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    final filtered = state.invoices.where((inv) {
      final query = _searchController.text.toLowerCase();
      final matchesQuery = query.isEmpty ||
          inv.invoiceNumber.toLowerCase().contains(query) ||
          inv.customerName.toLowerCase().contains(query) ||
          inv.customerPhone.toLowerCase().contains(query);

      final matchesStatus =
          _statusFilter == 'All' || inv.status == _statusFilter;

      return matchesQuery && matchesStatus;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Column(
        children: [
          HeaderBar(
            title: 'Invoices & Sales History',
            subtitle:
                'Search past tax invoices, view GST breakdown & reprint A4 bills',
            actions: [
              ElevatedButton.icon(
                onPressed: () => state.setViewIndex(1),
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
                label: const Text('Create New Bill'),
              ),
            ],
          ),

          // Search and Filters Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText:
                          'Search by Invoice #, Customer name or Mobile number...',
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
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    initialValue: _statusFilter,
                    isDense: true,
                    decoration: InputDecoration(
                      labelText: 'Status Filter',
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'All', child: Text('All Bills')),
                      DropdownMenuItem(value: 'Paid', child: Text('Paid Bills')),
                      DropdownMenuItem(
                          value: 'Due', child: Text('Credit / Due Bills')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _statusFilter = val);
                    },
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Invoices Table
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
                      0: FlexColumnWidth(1.6), // Inv #
                      1: FlexColumnWidth(2.2), // Customer
                      2: FlexColumnWidth(2.2), // Date
                      3: FlexColumnWidth(1.3), // Mode
                      4: FlexColumnWidth(1.5), // Taxable
                      5: FlexColumnWidth(1.4), // GST
                      6: FlexColumnWidth(1.6), // Grand Total
                      7: FlexColumnWidth(1.2), // Status
                      8: FlexColumnWidth(1.2), // Action
                    },
                    children: [
                      TableRow(
                        decoration:
                            BoxDecoration(color: Colors.grey.shade100),
                        children: [
                          _buildTh('Invoice No.'),
                          _buildTh('Customer'),
                          _buildTh('Date & Time'),
                          _buildTh('Payment Mode'),
                          _buildTh('Taxable Val'),
                          _buildTh('Total GST'),
                          _buildTh('Grand Total'),
                          _buildTh('Status'),
                          _buildTh('A4 Print', align: TextAlign.center),
                        ],
                      ),
                      ...filtered.map((inv) {
                        final totalGst = inv.isInterState
                            ? inv.totalIgst
                            : (inv.totalCgst + inv.totalSgst);

                        return TableRow(
                          children: [
                            _buildTd(
                              inv.invoiceNumber,
                              isBold: true,
                              color: const Color(0xFF2563EB),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    inv.customerName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                  if (inv.customerPhone.isNotEmpty)
                                    Text(
                                      inv.customerPhone,
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade600),
                                    ),
                                ],
                              ),
                            ),
                            _buildTd(dateFormat.format(inv.date)),
                            _buildTd(inv.paymentMode),
                            _buildTd('₹ ${currency.format(inv.subtotal)}'),
                            _buildTd('₹ ${currency.format(totalGst)}'),
                            _buildTd(
                              '₹ ${currency.format(inv.grandTotal)}',
                              isBold: true,
                              color: const Color(0xFF0F172A),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: inv.status == 'Paid'
                                        ? Colors.green.shade50
                                        : Colors.orange.shade50,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: inv.status == 'Paid'
                                          ? Colors.green.shade300
                                          : Colors.orange.shade300,
                                    ),
                                  ),
                                  child: Text(
                                    inv.status,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: inv.status == 'Paid'
                                          ? Colors.green.shade800
                                          : Colors.orange.shade800,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Center(
                              child: IconButton(
                                icon: const Icon(Icons.print_rounded, size: 20),
                                color: const Color(0xFF2563EB),
                                tooltip: 'Preview & Print A4 Invoice',
                                onPressed: () {
                                  InvoiceDialog.show(
                                    context,
                                    invoice: inv,
                                    settings: state.settings,
                                  );
                                },
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
