class ShopSettings {
  String shopName;
  String tagline;
  String address;
  String phone;
  String email;
  String gstin;
  String state;
  String stateCode;
  String bankName;
  String accountNumber;
  String ifscCode;
  String upiId;
  String invoicePrefix;
  int nextInvoiceNumber;
  String termsAndConditions;
  String currencySymbol;
  bool isInterState; // Whether to apply IGST by default

  ShopSettings({
    this.shopName = 'Sha Electronics & Mobiles',
    this.tagline = 'Sales, Accessories & Smart Services',
    this.address = 'Shop No. 4, Tech Plaza, Station Road, Mumbai',
    this.phone = '+91 98765 43210',
    this.email = 'contact@shaelectronics.com',
    this.gstin = '27AAAAA0000A1Z5',
    this.state = 'Maharashtra',
    this.stateCode = '27',
    this.bankName = 'HDFC Bank',
    this.accountNumber = '50200012345678',
    this.ifscCode = 'HDFC0001234',
    this.upiId = 'shaelectronics@okaxis',
    this.invoicePrefix = 'SHA-2026-',
    this.nextInvoiceNumber = 1001,
    this.termsAndConditions =
        '1. Goods once sold will not be taken back without original bill.\n2. Manufacturer warranty applies as per brand policy.\n3. Physical damage and water damage are not covered under warranty.\n4. Subject to local jurisdiction only.',
    this.currencySymbol = '₹',
    this.isInterState = false,
  });

  Map<String, dynamic> toJson() => {
        'shopName': shopName,
        'tagline': tagline,
        'address': address,
        'phone': phone,
        'email': email,
        'gstin': gstin,
        'state': state,
        'stateCode': stateCode,
        'bankName': bankName,
        'accountNumber': accountNumber,
        'ifscCode': ifscCode,
        'upiId': upiId,
        'invoicePrefix': invoicePrefix,
        'nextInvoiceNumber': nextInvoiceNumber,
        'termsAndConditions': termsAndConditions,
        'currencySymbol': currencySymbol,
        'isInterState': isInterState,
      };

  factory ShopSettings.fromJson(Map<String, dynamic> json) => ShopSettings(
        shopName: json['shopName'] ?? 'Sha Electronics & Mobiles',
        tagline: json['tagline'] ?? 'Sales, Accessories & Smart Services',
        address: json['address'] ?? 'Shop No. 4, Tech Plaza, Station Road, Mumbai',
        phone: json['phone'] ?? '+91 98765 43210',
        email: json['email'] ?? 'contact@shaelectronics.com',
        gstin: json['gstin'] ?? '27AAAAA0000A1Z5',
        state: json['state'] ?? 'Maharashtra',
        stateCode: json['stateCode'] ?? '27',
        bankName: json['bankName'] ?? 'HDFC Bank',
        accountNumber: json['accountNumber'] ?? '50200012345678',
        ifscCode: json['ifscCode'] ?? 'HDFC0001234',
        upiId: json['upiId'] ?? 'shaelectronics@okaxis',
        invoicePrefix: json['invoicePrefix'] ?? 'SHA-2026-',
        nextInvoiceNumber: json['nextInvoiceNumber'] ?? 1001,
        termsAndConditions: json['termsAndConditions'] ??
            '1. Goods once sold will not be taken back without original bill.\n2. Manufacturer warranty applies as per brand policy.',
        currencySymbol: json['currencySymbol'] ?? '₹',
        isInterState: json['isInterState'] ?? false,
      );
}

