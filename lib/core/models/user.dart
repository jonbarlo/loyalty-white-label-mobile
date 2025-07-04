class User {
  final int id;
  final int? businessId;
  final String email;
  final String name;
  final String role;
  final bool isActive;

  User({
    required this.id,
    this.businessId,
    required this.email,
    required this.name,
    required this.role,
    required this.isActive,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      businessId: json['businessId'],
      email: json['email'],
      name: json['name'],
      role: json['role'],
      isActive: json['isActive'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'businessId': businessId,
      'email': email,
      'name': name,
      'role': role,
      'isActive': isActive,
    };
  }

  User copyWith({
    int? id,
    int? businessId,
    String? email,
    String? name,
    String? role,
    bool? isActive,
  }) {
    return User(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, businessId: $businessId, email: $email, name: $name, role: $role, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.businessId == businessId &&
        other.email == email &&
        other.name == name &&
        other.role == role &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        businessId.hashCode ^
        email.hashCode ^
        name.hashCode ^
        role.hashCode ^
        isActive.hashCode;
  }
} 