class Reward {
  final int id;
  final int businessId;
  final int rewardProgramId;
  final String name;
  final String description;
  final String type;
  final double value;
  final bool isActive;

  Reward({
    required this.id,
    required this.businessId,
    required this.rewardProgramId,
    required this.name,
    required this.description,
    required this.type,
    required this.value,
    required this.isActive,
  });

  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward(
      id: json['id'],
      businessId: json['businessId'],
      rewardProgramId: json['rewardProgramId'],
      name: json['name'],
      description: json['description'],
      type: json['type'],
      value: (json['value'] as num).toDouble(),
      isActive: json['isActive'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'businessId': businessId,
      'rewardProgramId': rewardProgramId,
      'name': name,
      'description': description,
      'type': type,
      'value': value,
      'isActive': isActive,
    };
  }

  Reward copyWith({
    int? id,
    int? businessId,
    int? rewardProgramId,
    String? name,
    String? description,
    String? type,
    double? value,
    bool? isActive,
  }) {
    return Reward(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      rewardProgramId: rewardProgramId ?? this.rewardProgramId,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      value: value ?? this.value,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'Reward(id: $id, businessId: $businessId, rewardProgramId: $rewardProgramId, name: $name, description: $description, type: $type, value: $value, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Reward &&
        other.id == id &&
        other.businessId == businessId &&
        other.rewardProgramId == rewardProgramId &&
        other.name == name &&
        other.description == description &&
        other.type == type &&
        other.value == value &&
        other.isActive == isActive;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        businessId.hashCode ^
        rewardProgramId.hashCode ^
        name.hashCode ^
        description.hashCode ^
        type.hashCode ^
        value.hashCode ^
        isActive.hashCode;
  }
} 