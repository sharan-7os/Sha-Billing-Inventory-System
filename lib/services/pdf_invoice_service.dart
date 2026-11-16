import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/invoice.dart';
import '../models/shop_settings.dart';

class PdfInvoiceService {
  static Future<Uint8List> generateInvoicePdf(
    Invoice invoice,
    ShopSettings settings,
  ) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();

    final dateFormat = DateFormat('dd-MM-yyyy hh:mm a');
    final currencyFormat = NumberFormat('#,##,##0.00');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        theme: pw.ThemeData.withFont(
          base: font,
          bold: fontBold,
        ),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header with Title and Copy Type
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'TAX INVOICE',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blueGrey900,
                    ),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey500),
                      borderRadius:
                          const pw.BorderRadius.all(pw.Radius.circular(4)),
                    ),
                    child: pw.Text(
                      'Original for Recipient',
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 8),

              // Seller Details Banner
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue50,
                  borderRadius:
                      const pw.BorderRadius.all(pw.Radius.circular(6)),
                  border: pw.Border.all(color: PdfColors.blue200),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      flex: 3,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            settings.shopName,
                            style: pw.TextStyle(
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.blue900,
                            ),
                          ),
                          pw.Text(
                            settings.tagline,
                            style: const pw.TextStyle(
                              fontSize: 9,
                              color: PdfColors.grey700,
                            ),
                          ),
                          pw.SizedBox(height: 3),
                          pw.Text(
                            settings.address,
                            style: const pw.TextStyle(fontSize: 9),
                          ),
                          pw.Text(
                            'Phone: ${settings.phone} | Email: ${settings.email}',
                            style: const pw.TextStyle(fontSize: 9),
                          ),
                        ],
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text(
                            'GSTIN: ${settings.gstin}',
                            style: pw.TextStyle(
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.blueGrey900,
                            ),
                          ),
                          pw.Text(
                            'State: ${settings.state} (Code: ${settings.stateCode})',
                            style: const pw.TextStyle(fontSize: 9),
                          ),
                          pw.Text(
                            'PAN: ${settings.gstin.length >= 12 ? settings.gstin.substring(2, 12) : "-"}',
                            style: const pw.TextStyle(fontSize: 9),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 10),

              // Two Box Grid: Bill To & Invoice Info
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Billed To
                  pw.Expanded(
                    child: pw.Container(
                      height: 85,
                      padding: const pw.EdgeInsets.all(8),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey300),
                        borderRadius:
                            const pw.BorderRadius.all(pw.Radius.circular(4)),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'BILLED TO / BUYER DETAILS',
                            style: pw.TextStyle(
                              fontSize: 8,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.grey700,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            invoice.customerName,
                            style: pw.TextStyle(
                              fontSize: 11,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          if (invoice.customerPhone.isNotEmpty)
                            pw.Text(
                              'Phone: ${invoice.customerPhone}',
                              style: const pw.TextStyle(fontSize: 8.5),
                            ),
                          if (invoice.customerAddress != null &&
                              invoice.customerAddress!.isNotEmpty)
                            pw.Text(
                              'Address: ${invoice.customerAddress}',
                              style: const pw.TextStyle(fontSize: 8.5),
                              maxLines: 2,
                            ),
                          if (invoice.customerGstin != null &&
                              invoice.customerGstin!.isNotEmpty)
                            pw.Text(
                              'Customer GSTIN: ${invoice.customerGstin}',
                              style: pw.TextStyle(
                                fontSize: 8.5,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.blueGrey800,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 8),

                  // Invoice Meta
                  pw.Expanded(
                    child: pw.Container(
                      height: 85,
                      padding: const pw.EdgeInsets.all(8),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey300),
                        borderRadius:
                            const pw.BorderRadius.all(pw.Radius.circular(4)),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('Invoice No:',
                                  style: pw.TextStyle(
                                      fontSize: 9,
                                      fontWeight: pw.FontWeight.bold)),
                              pw.Text(invoice.invoiceNumber,
                                  style: pw.TextStyle(
                                      fontSize: 10,
                                      fontWeight: pw.FontWeight.bold,
                                      color: PdfColors.blue800)),
                            ],
                          ),
                          pw.SizedBox(height: 3),
                          pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('Date & Time:',
                                  style: const pw.TextStyle(fontSize: 8.5)),
                              pw.Text(dateFormat.format(invoice.date),
                                  style: const pw.TextStyle(fontSize: 8.5)),
                            ],
                          ),
                          pw.SizedBox(height: 3),
                          pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('Payment Mode:',
                                  style: const pw.TextStyle(fontSize: 8.5)),
                              pw.Text(
                                invoice.paymentMode +
                                    (invoice.paymentRef != null &&
                                            invoice.paymentRef!.isNotEmpty
                                        ? ' (${invoice.paymentRef})'
                                        : ''),
                                style: pw.TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: pw.FontWeight.bold),
                              ),
                            ],
                          ),
                          pw.SizedBox(height: 3),
                          pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('Place of Supply:',
                                  style: const pw.TextStyle(fontSize: 8.5)),
                              pw.Text(
                                  '${settings.state} (${settings.stateCode})',
                                  style: const pw.TextStyle(fontSize: 8.5)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 10),

              // Items Table
              pw.Expanded(
                child: pw.Table(
                  border: pw.TableBorder.all(
                    color: PdfColors.grey300,
                    width: 0.8,
                  ),
                  columnWidths: {
                    0: const pw.FixedColumnWidth(22), // S.No
                    1: const pw.FlexColumnWidth(3.2), // Item & Specs
                    2: const pw.FixedColumnWidth(48), // HSN
                    3: const pw.FixedColumnWidth(28), // Qty
                    4: const pw.FixedColumnWidth(48), // Rate
                    5: const pw.FixedColumnWidth(36), // Disc
                    6: const pw.FixedColumnWidth(52), // Taxable
                    7: const pw.FixedColumnWidth(38), // GST %
                    8: const pw.FixedColumnWidth(45), // Tax (₹)
                    9: const pw.FixedColumnWidth(55), // Total (₹)
                  },
                  children: [
                    // Table Header
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                      children: [
                        _buildTh('#', align: pw.TextAlign.center),
                        _buildTh('Item Description & Details'),
                        _buildTh('HSN/SAC', align: pw.TextAlign.center),
                        _buildTh('Qty', align: pw.TextAlign.center),
                        _buildTh('Rate', align: pw.TextAlign.right),
                        _buildTh('Disc', align: pw.TextAlign.right),
                        _buildTh('Taxable', align: pw.TextAlign.right),
                        _buildTh('GST', align: pw.TextAlign.center),
                        _buildTh('Tax Amt', align: pw.TextAlign.right),
                        _buildTh('Total (₹)', align: pw.TextAlign.right),
                      ],
                    ),
                    // Table Rows
                    ...invoice.items.asMap().entries.map((entry) {
                      final idx = entry.key + 1;
                      final item = entry.value;
                      final taxAmt = invoice.isInterState
                          ? item.totalTaxInter
                          : item.totalTaxIntra;
                      final lineTotal = invoice.isInterState
                          ? item.totalAmountInter
                          : item.totalAmountIntra;

                      return pw.TableRow(
                        children: [
                          _buildTd('$idx', align: pw.TextAlign.center),
                          pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(
                                horizontal: 4, vertical: 3),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  item.productName,
                                  style: pw.TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                                if (item.serialNumbers.isNotEmpty)
                                  pw.Text(
                                    'S/N: ${item.serialNumbers.join(", ")}',
                                    style: const pw.TextStyle(
                                      fontSize: 7.5,
                                      color: PdfColors.blueGrey700,
                                    ),
                                  ),
                                if (item.warranty.isNotEmpty &&
                                    item.warranty != 'No Warranty')
                                  pw.Text(
                                    'Warranty: ${item.warranty}',
                                    style: const pw.TextStyle(
                                      fontSize: 7.5,
                                      color: PdfColors.teal700,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          _buildTd(item.hsnCode, align: pw.TextAlign.center),
                          _buildTd('${item.quantity} ${item.unit}',
                              align: pw.TextAlign.center),
                          _buildTd(currencyFormat.format(item.unitPrice),
                              align: pw.TextAlign.right),
                          _buildTd(
                              item.discount > 0
                                  ? currencyFormat.format(item.discount)
                                  : '-',
                              align: pw.TextAlign.right),
                          _buildTd(currencyFormat.format(item.taxableAmount),
                              align: pw.TextAlign.right),
                          _buildTd('${item.gstRate.toInt()}%',
                              align: pw.TextAlign.center),
                          _buildTd(currencyFormat.format(taxAmt),
                              align: pw.TextAlign.right),
                          _buildTd(currencyFormat.format(lineTotal),
                              align: pw.TextAlign.right, isBold: true),
                        ],
                      );
                    }),
                  ],
                ),
              ),

              pw.SizedBox(height: 8),

              // Bottom Section: Words, Bank Details, and Totals
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Left side: Words + Bank + Terms
                  pw.Expanded(
                    flex: 3,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Container(
                          padding: const pw.EdgeInsets.all(5),
                          decoration: pw.BoxDecoration(
                            color: PdfColors.grey100,
                            borderRadius: const pw.BorderRadius.all(
                                pw.Radius.circular(3)),
                          ),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                'Amount Chargeable (in words):',
                                style: pw.TextStyle(
                                  fontSize: 8,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.grey800,
                                ),
                              ),
                              pw.Text(
                                'Indian Rupees ${_numberToWords(invoice.grandTotal.round())} Only',
                                style: pw.TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.blueGrey900,
                                ),
                              ),
                            ],
                          ),
                        ),
                        pw.SizedBox(height: 5),

                        // Bank Info
                        pw.Container(
                          padding: const pw.EdgeInsets.all(5),
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(
                                color: PdfColors.grey300, width: 0.5),
                            borderRadius: const pw.BorderRadius.all(
                                pw.Radius.circular(3)),
                          ),
                          child: pw.Row(
                            children: [
                              pw.Expanded(
                                child: pw.Column(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text(
                                      'BANK & PAYMENT DETAILS',
                                      style: pw.TextStyle(
                                        fontSize: 7.5,
                                        fontWeight: pw.FontWeight.bold,
                                        color: PdfColors.grey700,
                                      ),
                                    ),
                                    pw.Text(
                                      'Bank: ${settings.bankName} | A/C: ${settings.accountNumber}',
                                      style: const pw.TextStyle(fontSize: 8),
                                    ),
                                    pw.Text(
                                      'IFSC: ${settings.ifscCode} | UPI ID: ${settings.upiId}',
                                      style: const pw.TextStyle(fontSize: 8),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        pw.SizedBox(height: 5),

                        // Terms
                        pw.Text(
                          'Terms & Conditions:',
                          style: pw.TextStyle(
                            fontSize: 7.5,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.grey800,
                          ),
                        ),
                        pw.Text(
                          settings.termsAndConditions,
                          style: const pw.TextStyle(
                            fontSize: 6.8,
                            color: PdfColors.grey700,
                          ),
                          maxLines: 4,
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 12),

                  // Right side: Tax and Grand Total Box
                  pw.Expanded(
                    flex: 2,
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(6),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(
                            color: PdfColors.blueGrey300, width: 0.8),
                        borderRadius:
                            const pw.BorderRadius.all(pw.Radius.circular(4)),
                      ),
                      child: pw.Column(
                        children: [
                          _buildSummaryRow(
                              'Taxable Subtotal:',
                              '₹ ${currencyFormat.format(invoice.subtotal)}',
                              currencyFormat),
                          if (invoice.totalDiscount > 0)
                            _buildSummaryRow(
                                'Discount:',
                                '- ₹ ${currencyFormat.format(invoice.totalDiscount)}',
                                currencyFormat),
                          if (!invoice.isInterState) ...[
                            _buildSummaryRow(
                                'CGST:',
                                '₹ ${currencyFormat.format(invoice.totalCgst)}',
                                currencyFormat),
                            _buildSummaryRow(
                                'SGST:',
                                '₹ ${currencyFormat.format(invoice.totalSgst)}',
                                currencyFormat),
                          ] else
                            _buildSummaryRow(
                                'IGST:',
                                '₹ ${currencyFormat.format(invoice.totalIgst)}',
                                currencyFormat),
                          if (invoice.roundOff != 0.0)
                            _buildSummaryRow(
                                'Round Off:',
                                '₹ ${currencyFormat.format(invoice.roundOff)}',
                                currencyFormat),
                          pw.Divider(color: PdfColors.grey400, thickness: 0.5),
                          pw.Container(
                            padding: const pw.EdgeInsets.symmetric(
                                vertical: 4, horizontal: 4),
                            color: PdfColors.blue50,
                            child: pw.Row(
                              mainAxisAlignment:
                                  pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Text(
                                  'GRAND TOTAL:',
                                  style: pw.TextStyle(
                                    fontSize: 10,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.blue900,
                                  ),
                                ),
                                pw.Text(
                                  '₹ ${currencyFormat.format(invoice.grandTotal)}',
                                  style: pw.TextStyle(
                                    fontSize: 11,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.blue900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          pw.SizedBox(height: 3),
                          _buildSummaryRow(
                              'Amount Paid:',
                              '₹ ${currencyFormat.format(invoice.amountPaid)}',
                              currencyFormat),
                          if (invoice.amountDue > 0)
                            _buildSummaryRow(
                              'Balance Due:',
                              '₹ ${currencyFormat.format(invoice.amountDue)}',
                              currencyFormat,
                              isDue: true,
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 10),

              // Signature Footer
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'E. & O.E. | Thank you for your business!',
                    style: const pw.TextStyle(
                      fontSize: 8,
                      color: PdfColors.grey600,
                    ),
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        'For ${settings.shopName}',
                        style: pw.TextStyle(
                          fontSize: 8.5,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 25),
                      pw.Container(
                        width: 140,
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(
                            top: pw.BorderSide(
                                color: PdfColors.grey600, width: 0.5),
                          ),
                        ),
                        child: pw.Center(
                          child: pw.Text(
                            'Authorized Signatory',
                            style: const pw.TextStyle(fontSize: 7.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildTh(String text,
      {pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          fontSize: 7.8,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.blueGrey900,
        ),
      ),
    );
  }

  static pw.Widget _buildTd(
    String text, {
    pw.TextAlign align = pw.TextAlign.left,
    bool isBold = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          fontSize: 8,
          fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  static pw.Widget _buildSummaryRow(
    String title,
    String value,
    NumberFormat format, {
    bool isDue = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1.5, horizontal: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 8.5,
              fontWeight: isDue ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: isDue ? PdfColors.red800 : PdfColors.grey800,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 8.5,
              fontWeight: isDue ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: isDue ? PdfColors.red800 : PdfColors.black,
            ),
          ),
        ],
      ),
    );
  }

  static String _numberToWords(int number) {
    if (number == 0) return 'Zero';
    if (number < 0) return 'Minus ${_numberToWords(-number)}';

    final units = [
      '',
      'One',
      'Two',
      'Three',
      'Four',
      'Five',
      'Six',
      'Seven',
      'Eight',
      'Nine',
      'Ten',
      'Eleven',
      'Twelve',
      'Thirteen',
      'Fourteen',
      'Fifteen',
      'Sixteen',
      'Seventeen',
      'Eighteen',
      'Nineteen'
    ];

    final tens = [
      '',
      '',
      'Twenty',
      'Thirty',
      'Forty',
      'Fifty',
      'Sixty',
      'Seventy',
      'Eighty',
      'Ninety'
    ];

    String convertChunk(int n) {
      String str = '';
      if (n >= 100) {
        str += '${units[n ~/ 100]} Hundred ';
        n %= 100;
      }
      if (n >= 20) {
        str += '${tens[n ~/ 10]} ';
        n %= 10;
      }
      if (n > 0) {
        str += '${units[n]} ';
      }
      return str.trim();
    }

    String words = '';

    // Indian Numbering System: Crores (1,00,00,000), Lakhs (1,00,000), Thousands (1,000), Hundreds
    if (number >= 10000000) {
      words += '${convertChunk(number ~/ 10000000)} Crore ';
      number %= 10000000;
    }
    if (number >= 100000) {
      words += '${convertChunk(number ~/ 100000)} Lakh ';
      number %= 100000;
    }
    if (number >= 1000) {
      words += '${convertChunk(number ~/ 1000)} Thousand ';
      number %= 1000;
    }
    if (number > 0) {
      words += convertChunk(number);
    }

    return words.trim();
  }
}

