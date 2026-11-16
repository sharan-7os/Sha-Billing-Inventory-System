class Supplier {
  String id;
  String name;
  String company;
  String phone;
  String? email;
  String? address;
  String? gstin;
  DateTime createdAt;

  Supplier({
    required this.id,
    required this.name,
    required this.company,
    required this.phone,
    this.email,
    this.address,
    this.gstin,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'company': company,
        'phone': phone,
        'email': email,
        'address': address,
        'gstin': gstin,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Supplier.fromJson(Map<String, dynamic> json) => Supplier(
        id: json['id'],
        name: json['name'],
        company: json['company'] ?? '',
        phone: json['phone'],
        email: json['email'],
        address: json['address'],
        gstin: json['gstin'],
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : DateTime.now(),
      );
}

