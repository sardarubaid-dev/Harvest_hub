content = """class ReviewModel {
  final String id;
  final String productId;
  final String farmerId;
  final String userId;
  final String userName;
  final String? userAvatar;
  final int rating;
  final String comment;
  final List<String> mediaUrls;
  final bool isVerifiedPurchase;
  final int helpfulCount;
  final List<String> helpfulUserIds;
  final Map<String, dynamic>? farmerReply;
  final String status;
  final DateTime createdAt;
  final bool isApproved;

  ReviewModel({
    required this.id,
    required this.productId,
    required this.farmerId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    this.rating = 5,
    required this.comment,
    this.mediaUrls = const [],
    this.isVerifiedPurchase = false,
    this.helpfulCount = 0,
    this.helpfulUserIds = const [],
    this.farmerReply,
    this.status = 'published',
    required this.createdAt,
    this.isApproved = false,
  });

  factory ReviewModel.fromMap(String id, Map<String, dynamic> map) {
    return ReviewModel(
      id: id,
      productId: map['productId'] ?? '',
      farmerId: map['farmerId'] ?? '',
      userId: map['userId'] ?? map['customerId'] ?? '',
      userName: map['userName'] ?? map['customerName'] ?? '',
      userAvatar: map['userAvatar'] ?? map['customerAvatar'],
      rating: (map['rating'] ?? 5).toInt(),
      comment: map['comment'] ?? '',
      mediaUrls: List<String>.from(map['mediaUrls'] ?? []),
      isVerifiedPurchase: map['isVerifiedPurchase'] ?? false,
      helpfulCount: (map['helpfulCount'] ?? 0).toInt(),
      helpfulUserIds: List<String>.from(map['helpfulUserIds'] ?? []),
      farmerReply: map['farmerReply'],
      status: map['status'] ?? 'published',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] is String ? DateTime.parse(map['createdAt']) : DateTime.parse(map['createdAt'].toString()))
          : (map['Created_At'] != null
              ? DateTime.parse(map['Created_At'].toString())
              : DateTime.now()),
      isApproved: map['isApproved'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'farmerId': farmerId,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'rating': rating,
      'comment': comment,
      'mediaUrls': mediaUrls,
      'isVerifiedPurchase': isVerifiedPurchase,
      'helpfulCount': helpfulCount,
      'helpfulUserIds': helpfulUserIds,
      'farmerReply': farmerReply,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'isApproved': isApproved,
    };
  }

  ReviewModel copyWith({
    String? id,
    String? productId,
    String? farmerId,
    String? userId,
    String? userName,
    String? userAvatar,
    int? rating,
    String? comment,
    List<String>? mediaUrls,
    bool? isVerifiedPurchase,
    int? helpfulCount,
    List<String>? helpfulUserIds,
    Map<String, dynamic>? farmerReply,
    String? status,
    DateTime? createdAt,
    bool? isApproved,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      farmerId: farmerId ?? this.farmerId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      isVerifiedPurchase: isVerifiedPurchase ?? this.isVerifiedPurchase,
      helpfulCount: helpfulCount ?? this.helpfulCount,
      helpfulUserIds: helpfulUserIds ?? this.helpfulUserIds,
      farmerReply: farmerReply ?? this.farmerReply,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      isApproved: isApproved ?? this.isApproved,
    );
  }
}
"""

with open('lib/models/review_model.dart', 'w', encoding='utf-8') as f:
    f.write(content)
print("File rewritten.")
