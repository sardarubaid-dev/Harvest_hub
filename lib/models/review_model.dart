class ReviewModel {
  final String id;
  final String customerId;
  final String customerName;
  final String? customerAvatar;
  final String targetType;
  final String targetId;
  final double rating;
  final String comment;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.customerId,
    required this.customerName,
    this.customerAvatar,
    this.targetType = 'farmer',
    required this.targetId,
    this.rating = 5.0,
    required this.comment,
    required this.createdAt,
  });

  factory ReviewModel.fromMap(String id, Map<String, dynamic> map) {
    return ReviewModel(
      id: id,
      customerId: map['customerId'] ?? map['Customer_Id'] ?? '',
      customerName: map['customerName'] ?? map['Customer_Name'] ?? '',
      customerAvatar: map['customerAvatar'] ?? map['Customer_Avatar'],
      targetType: map['targetType'] ?? map['Target_Type'] ?? 'farmer',
      targetId: map['targetId'] ?? map['Target_Id'] ?? '',
      rating: (map['rating'] ?? map['Rating'] ?? 5.0).toDouble(),
      comment: map['comment'] ?? map['Comment'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'].toString())
          : (map['Created_At'] != null
              ? DateTime.parse(map['Created_At'].toString())
              : DateTime.now()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'customerAvatar': customerAvatar,
      'targetType': targetType,
      'targetId': targetId,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  ReviewModel copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? customerAvatar,
    String? targetType,
    String? targetId,
    double? rating,
    String? comment,
    DateTime? createdAt,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerAvatar: customerAvatar ?? this.customerAvatar,
      targetType: targetType ?? this.targetType,
      targetId: targetId ?? this.targetId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
