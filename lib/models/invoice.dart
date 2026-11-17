class InvoiceItem {
  String productId;
  String productName;
  String barcode; // Product Code
  String get productCode => barcode;
  set productCode(String val) => barcode = val;
  String hsnCode;
  int quantity;
  String unit;
  double unitPrice;
  double discount; // Flat discount on this item
  double gstRate; // e.g. 18.0
  List<String> serialNumbers; // Serial / IMEI numbers
  String warranty;

  InvoiceItem({
    required this.productId,
    required this.productName,
    required this.barcode,
    required this.hsnCode,
    required this.quantity,
    this.unit = 'Pcs',
    required this.unitPrice,
    this.discount = 0.0,
    required this.gstRate,
    List<String>? serialNumbers,
    this.warranty = '1 Year',
  }) : serialNumbers = serialNumbers ?? [];

  double get grossAmount => unitPrice * quantity;
  double get taxableAmount => grossAmount - discount;
  double get cgstRate => gstRate / 2;
  double get sgstRate => gstRate / 2;
  double get cgstAmount => taxableAmount * (cgstRate / 100);
  double get sgstAmount => taxableAmount * (sgstRate / 100);
  double get igstAmount => taxableAmount * (gstRate / 100);
  double get totalTaxIntra => cgstAmount + sgstAmount;
  double get totalTaxInter => igstAmount;
  double get totalAmountIntra => taxableAmount + totalTaxIntra;
  double get totalAmountInter => taxableAmount + totalTaxInter;

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'productName': productName,
        'productCode': barcode,
        'barcode': barcode,
        'hsnCode': hsnCode,
        'quantity': quantity,
        'unit': unit,
        'unitPrice': unitPrice,
        'discount': discount,
        'gstRate': gstRate,
        'serialNumbers': serialNumbers,
        'warranty': warranty,
      };

  factory InvoiceItem.fromJson(Map<String, dynamic> json) => InvoiceItem(
        productId: json['productId'],
        productName: json['productName'],
        barcode: json['productCode'] ?? json['barcode'] ?? '',
        hsnCode: json['hsnCode'] ?? '8517',
        quantity: (json['quantity'] as num).toInt(),
        unit: json['unit'] ?? 'Pcs',
        unitPrice: (json['unitPrice'] as num).toDouble(),
        discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
        gstRate: (json['gstRate'] as num).toDouble(),
        serialNumbers: (json['serialNumbers'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        warranty: json['warranty'] ?? '1 Year',
      );
}

class Invoice {
  String id;
  String invoiceNumber;
  DateTime date;
  String customerName;
  String customerPhone;
  String? customerAddress;
  String? customerGstin;
  List<InvoiceItem> items;
  double subtotal; // Total Taxable Amount
  double totalDiscount;
  double totalCgst;
  double totalSgst;
  double totalIgst;
  double roundOff;
  double grandTotal;
  double amountPaid;
  double amountDue;
  String paymentMode; // Cash, UPI, Card, Net Banking, Due
  String? paymentRef; // Transaction / UPI Reference
  bool isInterState; // true => IGST, false => CGST + SGST
  String status; // 'Paid', 'Partial', 'Due', 'Cancelled'
  String? notes;

  Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.date,
    required this.customerName,
    required this.customerPhone,
    this.customerAddress,
    this.customerGstin,
    required this.items,
    required this.subtotal,
    this.totalDiscount = 0.0,
    required this.totalCgst,
    required this.totalSgst,
    this.totalIgst = 0.0,
    this.roundOff = 0.0,
    required this.grandTotal,
    required this.amountPaid,
    required this.amountDue,
    this.paymentMode = 'Cash',
    this.paymentRef,
    this.isInterState = false,
    this.status = 'Paid',
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'invoiceNumber': invoiceNumber,
        'date': date.toIso8601String(),
        'customerName': customerName,
        'customerPhone': customerPhone,
        'customerAddress': customerAddress,
        'customerGstin': customerGstin,
        'items': items.map((i) => i.toJson()).toList(),
        'subtotal': subtotal,
        'totalDiscount': totalDiscount,
        'totalCgst': totalCgst,
        'totalSgst': totalSgst,
        'totalIgst': totalIgst,
        'roundOff': roundOff,
        'grandTotal': grandTotal,
        'amountPaid': amountPaid,
        'amountDue': amountDue,
        'paymentMode': paymentMode,
        'paymentRef': paymentRef,
        'isInterState': isInterState,
        'status': status,
        'notes': notes,
      };

  factory Invoice.fromJson(Map<String, dynamic> json) => Invoice(
        id: json['id'],
        invoiceNumber: json['invoiceNumber'],
        date: DateTime.parse(json['date']),
        customerName: json['customerName'] ?? 'Walk-in Customer',
        customerPhone: json['customerPhone'] ?? '',
        customerAddress: json['customerAddress'],
        customerGstin: json['customerGstin'],
        items: (json['items'] as List<dynamic>)
            .map((item) => InvoiceItem.fromJson(item))
            .toList(),
        subtotal: (json['subtotal'] as num).toDouble(),
        totalDiscount: (json['totalDiscount'] as num?)?.toDouble() ?? 0.0,
        totalCgst: (json['totalCgst'] as num).toDouble(),
        totalSgst: (json['totalSgst'] as num).toDouble(),
        totalIgst: (json['totalIgst'] as num?)?.toDouble() ?? 0.0,
        roundOff: (json['roundOff'] as num?)?.toDouble() ?? 0.0,
        grandTotal: (json['grandTotal'] as num).toDouble(),
        amountPaid: (json['amountPaid'] as num).toDouble(),
        amountDue: (json['amountDue'] as num).toDouble(),
        paymentMode: json['paymentMode'] ?? 'Cash',
        paymentRef: json['paymentRef'],
        isInterState: json['isInterState'] ?? false,
        status: json['status'] ?? 'Paid',
        notes: json['notes'],
      );
}

