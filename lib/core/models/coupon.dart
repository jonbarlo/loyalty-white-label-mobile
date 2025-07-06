class Coupon {
  final int id;
  final int businessId;
  final String title;
  final String description;
  final String code;
  final double discountValue;
  final String discountType; // 'percentage' or 'fixed_amount'
  final double minimumPurchase;
  final double? maximumDiscount;
  final DateTime startDate;
  final DateTime endDate;
  final int totalQuantity;
  final int usedQuantity;
  final int perCustomerLimit;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Coupon({
    required this.id,
    required this.businessId,
    required this.title,
    required this.description,
    required this.code,
    required this.discountValue,
    required this.discountType,
    required this.minimumPurchase,
    this.maximumDiscount,
    required this.startDate,
    required this.endDate,
    required this.totalQuantity,
    required this.usedQuantity,
    required this.perCustomerLimit,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: json['id'],
      businessId: json['businessId'],
      title: json['name'], // API uses 'name' instead of 'title'
      description: json['description'],
      code: json['couponCode'], // API uses 'couponCode' instead of 'code'
      discountValue: (json['discountValue'] as num).toDouble(),
      discountType: json['discountType'],
      minimumPurchase: (json['minimumPurchase'] as num).toDouble(),
      maximumDiscount: json['maximumDiscount'] != null ? (json['maximumDiscount'] as num).toDouble() : null,
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      totalQuantity: json['totalQuantity'],
      usedQuantity: json['usedQuantity'],
      perCustomerLimit: json['perCustomerLimit'],
      isActive: json['isActive'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'businessId': businessId,
      'name': title, // API expects 'name' instead of 'title'
      'description': description,
      'couponCode': code, // API expects 'couponCode' instead of 'code'
      'discountValue': discountValue,
      'discountType': discountType,
      'minimumPurchase': minimumPurchase,
      'maximumDiscount': maximumDiscount,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'totalQuantity': totalQuantity,
      'usedQuantity': usedQuantity,
      'perCustomerLimit': perCustomerLimit,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  bool get isExpired => DateTime.now().isAfter(endDate);
  bool get isAvailable => isActive && !isExpired && usedQuantity < totalQuantity;
  String get discountDisplay => discountType == 'percentage' 
    ? '${discountValue.toInt()}% OFF' 
    : '\$${discountValue.toStringAsFixed(2)} OFF';

  Coupon copyWith({
    int? id,
    int? businessId,
    String? title,
    String? description,
    String? code,
    double? discountValue,
    String? discountType,
    double? minimumPurchase,
    double? maximumDiscount,
    DateTime? startDate,
    DateTime? endDate,
    int? totalQuantity,
    int? usedQuantity,
    int? perCustomerLimit,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Coupon(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      title: title ?? this.title,
      description: description ?? this.description,
      code: code ?? this.code,
      discountValue: discountValue ?? this.discountValue,
      discountType: discountType ?? this.discountType,
      minimumPurchase: minimumPurchase ?? this.minimumPurchase,
      maximumDiscount: maximumDiscount ?? this.maximumDiscount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      totalQuantity: totalQuantity ?? this.totalQuantity,
      usedQuantity: usedQuantity ?? this.usedQuantity,
      perCustomerLimit: perCustomerLimit ?? this.perCustomerLimit,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 