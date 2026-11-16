import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../widgets/header_bar.dart';
import '../widgets/stat_card.dart';

class ReportsView extends StatelessWidget {
  const ReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final currency = NumberFormat('#,##,##0.00');

    // Aggregate GST collections
    double totalTaxable = 0.0;
    double totalCgst = 0.0;
    double totalSgst = 0.0;
    double totalIgst = 0.0;
    double totalGrand = 0.0;

    // Payment Mode Breakdown
    double cashSales = 0.0;
    double upiSales = 0.0;
    double cardSales = 0.0;
    double dueSales = 0.0;

    // HSN Code Map: HSN -> {qty, taxable, tax, total}
    final Map<String, _HsnSummary> hsnMap = {};

    for (final inv in state.invoices) {
      if (inv.status == 'Cancelled') continue;

      totalTaxable += inv.subtotal;
      totalCgst += inv.totalCgst;
      totalSgst += inv.totalSgst;
      totalIgst += inv.totalIgst;
      totalGrand += inv.grandTotal;

      if (inv.paymentMode == 'Cash') cashSales += inv.grandTotal;
      if (inv.paymentMode == 'UPI') upiSales += inv.grandTotal;
      if (inv.paymentMode == 'Card') cardSales += inv.grandTotal;
      if (inv.paymentMode == 'Due') dueSales += inv.grandTotal;

      for (final item in inv.items) {
        final taxAmt =
            inv.isInterState ? item.totalTaxInter : item.totalTaxIntra;
        final itemTotal =
            inv.isInterState ? item.totalAmountInter : item.totalAmountIntra;

        if (!hsnMap.containsKey(item.hsnCode)) {
          hsnMap[item.hsnCode] = _HsnSummary(
            hsn: item.hsnCode,
            description: item.productName,
            gstRate: item.gstRate,
          );
        }
        final h = hsnMap[item.hsnCode]!;
        h.quantity += item.quantity;
        h.taxableValue += item.taxableAmount;
        h.taxAmount += taxAmt;
        h.totalAmount += itemTotal;
      }
    }

    final totalGstLiability = totalCgst + totalSgst + totalIgst;
    final margin = state.totalInventoryValue - state.totalInventoryCost;
    final marginPercent = state.totalInventoryCost > 0
        ? (margin / state.totalInventoryCost) * 100
        : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Column(
        children: [
          HeaderBar(
            title: 'Reports & GST Tax Summary',
            subtitle:
                'GSTR-1 filing tables, HSN summary, payment modes and inventory valuation',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top GST Metrics
                  Row(
                    children: [
                      StatCard(
                        title: 'Total Taxable Turnover',
                        value: '₹ ${currency.format(totalTaxable)}',
                        subtitle: 'Base value excl. GST',
                        icon: Icons.receipt_rounded,
                        color: const Color(0xFF2563EB),
                      ),
                      const SizedBox(width: 16),
                      StatCard(
                        title: 'Total GST Collected',
                        value: '₹ ${currency.format(totalGstLiability)}',
                        subtitle: 'CGST + SGST + IGST liability',
                        icon: Icons.account_balance_rounded,
                        color: const Color(0xFF10B981),
                      ),
                      const SizedBox(width: 16),
                      StatCard(
                        title: 'Total Gross Sales',
                        value: '₹ ${currency.format(totalGrand)}',
                        subtitle: '${state.invoices.length} Invoices generated',
                        icon: Icons.currency_rupee_rounded,
                        color: const Color(0xFF8B5CF6),
                      ),
                      const SizedBox(width: 16),
                      StatCard(
                        title: 'Stock Valuation Margin',
                        value:
                            '${marginPercent.toStringAsFixed(1)}% (₹ ${currency.format(margin)})',
                        subtitle: 'Est. Gross inventory profit',
                        icon: Icons.pie_chart_rounded,
                        color: const Color(0xFFF59E0B),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // GST Breakdown Box & Payment Breakdown Box
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // CGST / SGST / IGST Breakdown Box
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'GST Tax Collections Breakdown',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildTaxRow('Central GST (CGST)',
                                  '₹ ${currency.format(totalCgst)}', Colors.blue),
                              _buildTaxRow('State GST (SGST)',
                                  '₹ ${currency.format(totalSgst)}', Colors.teal),
                              _buildTaxRow(
                                  'Integrated GST (IGST - Inter-state)',
                                  '₹ ${currency.format(totalIgst)}',
                                  Colors.purple),
                              const Divider(height: 20),
                              _buildTaxRow(
                                'Total Tax Collected (Liability)',
                                '₹ ${currency.format(totalGstLiability)}',
                                const Color(0xFF0F172A),
                                isBold: true,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),

                      // Payment Method Breakdown Box
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Payment Channel Distribution',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildTaxRow('Cash Collections',
                                  '₹ ${currency.format(cashSales)}', Colors.green),
                              _buildTaxRow('UPI / QR Payments',
                                  '₹ ${currency.format(upiSales)}', Colors.blue),
                              _buildTaxRow('Card (Debit / Credit)',
                                  '₹ ${currency.format(cardSales)}', Colors.indigo),
                              _buildTaxRow('Customer Credit / Khata (Due)',
                                  '₹ ${currency.format(dueSales)}', Colors.red),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // HSN-wise Summary Table (Required for Indian GST filing)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'HSN / SAC Summary Table (GSTR-1 Ready)',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                Text(
                                  'Itemized HSN codes for GST portal monthly return filing',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${hsnMap.length} HSN Codes',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Table(
                            border: TableBorder(
                              horizontalInside: BorderSide(
                                  color: Colors.grey.shade200, width: 1),
                            ),
                            columnWidths: const {
                              0: FlexColumnWidth(1.6), // HSN Code
                              1: FlexColumnWidth(3.0), // Description
                              2: FlexColumnWidth(1.0), // GST Rate
                              3: FlexColumnWidth(1.2), // Total Qty
                              4: FlexColumnWidth(1.8), // Taxable Value
                              5: FlexColumnWidth(1.6), // Total Tax
                              6: FlexColumnWidth(1.8), // Total Value
                            },
                            children: [
                              TableRow(
                                decoration: BoxDecoration(
                                    color: Colors.grey.shade100),
                                children: [
                                  _buildTh('HSN / SAC Code'),
                                  _buildTh('Product Category / Description'),
                                  _buildTh('GST Rate', align: TextAlign.center),
                                  _buildTh('Total Qty', align: TextAlign.center),
                                  _buildTh('Taxable Val (₹)'),
                                  _buildTh('GST Amount (₹)'),
                                  _buildTh('Total Invoiced (₹)'),
                                ],
                              ),
                              ...hsnMap.values.map((hsn) {
                                return TableRow(
                                  children: [
                                    _buildTd(hsn.hsn,
                                        isBold: true,
                                        color: Colors.blue.shade700),
                                    _buildTd(hsn.description),
                                    _buildTd('${hsn.gstRate.toInt()}%',
                                        align: TextAlign.center),
                                    _buildTd('${hsn.quantity}',
                                        align: TextAlign.center),
                                    _buildTd(
                                        '₹ ${currency.format(hsn.taxableValue)}'),
                                    _buildTd(
                                        '₹ ${currency.format(hsn.taxAmount)}'),
                                    _buildTd(
                                      '₹ ${currency.format(hsn.totalAmount)}',
                                      isBold: true,
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ],
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaxRow(String label, String value, Color color,
      {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: isBold ? const Color(0xFF0F172A) : color,
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

class _HsnSummary {
  final String hsn;
  final String description;
  final double gstRate;
  int quantity = 0;
  double taxableValue = 0.0;
  double taxAmount = 0.0;
  double totalAmount = 0.0;

  _HsnSummary({
    required this.hsn,
    required this.description,
    required this.gstRate,
  });
}

