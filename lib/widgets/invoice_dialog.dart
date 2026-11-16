import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import '../models/invoice.dart';
import '../models/shop_settings.dart';
import '../services/pdf_invoice_service.dart';

class InvoiceDialog extends StatelessWidget {
  final Invoice invoice;
  final ShopSettings settings;

  const InvoiceDialog({
    super.key,
    required this.invoice,
    required this.settings,
  });

  static Future<void> show(
    BuildContext context, {
    required Invoice invoice,
    required ShopSettings settings,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => InvoiceDialog(
        invoice: invoice,
        settings: settings,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 1000,
        height: 750,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Top action bar
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.receipt_long_rounded, color: Colors.blue),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tax Invoice Preview: ${invoice.invoiceNumber}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'Customer: ${invoice.customerName} • Grand Total: ₹ ${invoice.grandTotal.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                  tooltip: 'Close',
                ),
              ],
            ),
            const Divider(height: 24),

            // PDF Preview Area
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: PdfPreview(
                  maxPageWidth: 700,
                  build: (PdfPageFormat format) =>
                      PdfInvoiceService.generateInvoicePdf(invoice, settings),
                  canChangePageFormat: false,
                  canChangeOrientation: false,
                  canDebug: false,
                  dynamicLayout: false,
                  actions: const [],
                  pdfFileName: 'Invoice_${invoice.invoiceNumber}.pdf',
                  loadingWidget: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

