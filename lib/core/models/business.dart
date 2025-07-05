class Business {
  final int id;
  final String name;
  final String? description;
  final String? address;
  final String? phone;
  final String? email;
  final String? website;
  final String? logoUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Business({
    required this.id,
    required this.name,
    this.description,
    this.address,
    this.phone,
    this.email,
    this.website,
    this.logoUrl,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      address: json['address'],
      phone: json['phone'],
      email: json['email'],
      website: json['website'],
      logoUrl: json['logoUrl'],
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'address': address,
      'phone': phone,
      'email': email,
      'website': website,
      'logoUrl': logoUrl,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Business copyWith({
    int? id,
    String? name,
    String? description,
    String? address,
    String? phone,
    String? email,
    String? website,
    String? logoUrl,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Business(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      website: website ?? this.website,
      logoUrl: logoUrl ?? this.logoUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Business(id: $id, name: $name, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Business && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
} 