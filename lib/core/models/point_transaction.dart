class PointTransaction {
  final int id;
  final int userId;
  final int businessId;
  final int rewardProgramId;
  final int points;
  final String type;
  final String description;

  PointTransaction({
    required this.id,
    required this.userId,
    required this.businessId,
    required this.rewardProgramId,
    required this.points,
    required this.type,
    required this.description,
  });

  factory PointTransaction.fromJson(Map<String, dynamic> json) {
    return PointTransaction(
      id: json['id'],
      userId: json['userId'],
      businessId: json['businessId'],
      rewardProgramId: json['rewardProgramId'],
      points: json['points'],
      type: json['type'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'businessId': businessId,
      'rewardProgramId': rewardProgramId,
      'points': points,
      'type': type,
      'description': description,
    };
  }

  PointTransaction copyWith({
    int? id,
    int? userId,
    int? businessId,
    int? rewardProgramId,
    int? points,
    String? type,
    String? description,
  }) {
    return PointTransaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      businessId: businessId ?? this.businessId,
      rewardProgramId: rewardProgramId ?? this.rewardProgramId,
      points: points ?? this.points,
      type: type ?? this.type,
      description: description ?? this.description,
    );
  }

  @override
  String toString() {
    return 'PointTransaction(id: $id, userId: $userId, businessId: $businessId, rewardProgramId: $rewardProgramId, points: $points, type: $type, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PointTransaction &&
        other.id == id &&
        other.userId == userId &&
        other.businessId == businessId &&
        other.rewardProgramId == rewardProgramId &&
        other.points == points &&
        other.type == type &&
        other.description == description;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        businessId.hashCode ^
        rewardProgramId.hashCode ^
        points.hashCode ^
        type.hashCode ^
        description.hashCode;
  }
} 