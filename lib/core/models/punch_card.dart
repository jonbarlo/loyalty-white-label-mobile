class PunchCard {
  final int id;
  final int userId;
  final int businessId;
  final int rewardProgramId;
  final int punches;
  final bool redeemed;

  PunchCard({
    required this.id,
    required this.userId,
    required this.businessId,
    required this.rewardProgramId,
    required this.punches,
    required this.redeemed,
  });

  factory PunchCard.fromJson(Map<String, dynamic> json) {
    return PunchCard(
      id: json['id'],
      userId: json['userId'],
      businessId: json['businessId'],
      rewardProgramId: json['rewardProgramId'],
      punches: json['punches'],
      redeemed: json['redeemed'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'businessId': businessId,
      'rewardProgramId': rewardProgramId,
      'punches': punches,
      'redeemed': redeemed,
    };
  }

  PunchCard copyWith({
    int? id,
    int? userId,
    int? businessId,
    int? rewardProgramId,
    int? punches,
    bool? redeemed,
  }) {
    return PunchCard(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      businessId: businessId ?? this.businessId,
      rewardProgramId: rewardProgramId ?? this.rewardProgramId,
      punches: punches ?? this.punches,
      redeemed: redeemed ?? this.redeemed,
    );
  }

  @override
  String toString() {
    return 'PunchCard(id: $id, userId: $userId, businessId: $businessId, rewardProgramId: $rewardProgramId, punches: $punches, redeemed: $redeemed)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PunchCard &&
        other.id == id &&
        other.userId == userId &&
        other.businessId == businessId &&
        other.rewardProgramId == rewardProgramId &&
        other.punches == punches &&
        other.redeemed == redeemed;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        businessId.hashCode ^
        rewardProgramId.hashCode ^
        punches.hashCode ^
        redeemed.hashCode;
  }
} 