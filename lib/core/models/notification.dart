class NotificationModel {
  final int id;
  final int userId;
  final int businessId;
  final String message;
  final String type;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.businessId,
    required this.message,
    required this.type,
    required this.isRead,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      userId: json['userId'],
      businessId: json['businessId'],
      message: json['message'],
      type: json['type'],
      isRead: json['isRead'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'businessId': businessId,
      'message': message,
      'type': type,
      'isRead': isRead,
    };
  }

  NotificationModel copyWith({
    int? id,
    int? userId,
    int? businessId,
    String? message,
    String? type,
    bool? isRead,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      businessId: businessId ?? this.businessId,
      message: message ?? this.message,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
    );
  }

  @override
  String toString() {
    return 'NotificationModel(id: $id, userId: $userId, businessId: $businessId, message: $message, type: $type, isRead: $isRead)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationModel &&
        other.id == id &&
        other.userId == userId &&
        other.businessId == businessId &&
        other.message == message &&
        other.type == type &&
        other.isRead == isRead;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        businessId.hashCode ^
        message.hashCode ^
        type.hashCode ^
        isRead.hashCode;
  }
} 