class Customer {
  String id;
  String name;
  String phone;
  String? email;
  String? address;
  String? gstin;
  double totalPurchases;
  double dueBalance;
  DateTime createdAt;

  Customer({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.address,
    this.gstin,
    this.totalPurchases = 0.0,
    this.dueBalance = 0.0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'email': email,
        'address': address,
        'gstin': gstin,
        'totalPurchases': totalPurchases,
        'dueBalance': dueBalance,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
        id: json['id'],
        name: json['name'],
        phone: json['phone'],
        email: json['email'],
        address: json['address'],
        gstin: json['gstin'],
        totalPurchases: (json['totalPurchases'] as num?)?.toDouble() ?? 0.0,
        dueBalance: (json['dueBalance'] as num?)?.toDouble() ?? 0.0,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : DateTime.now(),
      );

  Customer copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? address,
    String? gstin,
    double? totalPurchases,
    double? dueBalance,
    DateTime? createdAt,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      gstin: gstin ?? this.gstin,
      totalPurchases: totalPurchases ?? this.totalPurchases,
      dueBalance: dueBalance ?? this.dueBalance,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

