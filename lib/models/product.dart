class Product {
  String id;
  String name;
  String barcode; // Barcode or SKU
  String category;
  String brand;
  String hsnCode;
  double costPrice; // Cost / Purchase price
  double sellingPrice; // Retail price (excl. or base)
  double gstRate; // GST % (0, 5, 12, 18, 28)
  int stockQuantity;
  int lowStockThreshold;
  String unit; // Pcs, Box, Set, Meter
  String warranty; // e.g. "1 Year", "6 Months"
  bool requiresSerialNumber; // IMEI / Serial number tracking
  String? description;
  DateTime createdAt;

  Product({
    required this.id,
    required this.name,
    required this.barcode,
    required this.category,
    required this.brand,
    required this.hsnCode,
    required this.costPrice,
    required this.sellingPrice,
    this.gstRate = 18.0,
    required this.stockQuantity,
    this.lowStockThreshold = 5,
    this.unit = 'Pcs',
    this.warranty = '1 Year',
    this.requiresSerialNumber = false,
    this.description,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isLowStock => stockQuantity <= lowStockThreshold;
  bool get isOutOfStock => stockQuantity <= 0;

  // Valuation
  double get totalStockCost => costPrice * stockQuantity;
  double get totalStockValue => sellingPrice * stockQuantity;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'barcode': barcode,
        'category': category,
        'brand': brand,
        'hsnCode': hsnCode,
        'costPrice': costPrice,
        'sellingPrice': sellingPrice,
        'gstRate': gstRate,
        'stockQuantity': stockQuantity,
        'lowStockThreshold': lowStockThreshold,
        'unit': unit,
        'warranty': warranty,
        'requiresSerialNumber': requiresSerialNumber,
        'description': description,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'],
        name: json['name'],
        barcode: json['barcode'] ?? '',
        category: json['category'] ?? 'General',
        brand: json['brand'] ?? 'Generic',
        hsnCode: json['hsnCode'] ?? '8517',
        costPrice: (json['costPrice'] as num).toDouble(),
        sellingPrice: (json['sellingPrice'] as num).toDouble(),
        gstRate: (json['gstRate'] as num?)?.toDouble() ?? 18.0,
        stockQuantity: (json['stockQuantity'] as num).toInt(),
        lowStockThreshold: (json['lowStockThreshold'] as num?)?.toInt() ?? 5,
        unit: json['unit'] ?? 'Pcs',
        warranty: json['warranty'] ?? '1 Year',
        requiresSerialNumber: json['requiresSerialNumber'] ?? false,
        description: json['description'],
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : DateTime.now(),
      );

  Product copyWith({
    String? id,
    String? name,
    String? barcode,
    String? category,
    String? brand,
    String? hsnCode,
    double? costPrice,
    double? sellingPrice,
    double? gstRate,
    int? stockQuantity,
    int? lowStockThreshold,
    String? unit,
    String? warranty,
    bool? requiresSerialNumber,
    String? description,
    DateTime? createdAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      barcode: barcode ?? this.barcode,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      hsnCode: hsnCode ?? this.hsnCode,
      costPrice: costPrice ?? this.costPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      gstRate: gstRate ?? this.gstRate,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      unit: unit ?? this.unit,
      warranty: warranty ?? this.warranty,
      requiresSerialNumber: requiresSerialNumber ?? this.requiresSerialNumber,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

