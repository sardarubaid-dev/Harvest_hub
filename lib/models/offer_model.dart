class OfferModel {
  final String id;
  final String title;
  final String description;
  final double discountPercentage;
  final bool isActive;
  final String targetAudience; // 'all', 'customers', 'farmers'
  final DateTime createdAt;

  OfferModel({
    required this.id,
    required this.title,
    required this.description,
    this.discountPercentage = 0.0,
    this.isActive = false,
    this.targetAudience = 'all',
    required this.createdAt,
  });

  factory OfferModel.fromMap(String id, Map<String, dynamic> map) {
    return OfferModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      discountPercentage: (map['discountPercentage'] ?? 0.0).toDouble(),
      isActive: map['isActive'] ?? false,
      targetAudience: map['targetAudience'] ?? 'all',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'discountPercentage': discountPercentage,
      'isActive': isActive,
      'targetAudience': targetAudience,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  OfferModel copyWith({
    String? id,
    String? title,
    String? description,
    double? discountPercentage,
    bool? isActive,
    String? targetAudience,
    DateTime? createdAt,
  }) {
    return OfferModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      isActive: isActive ?? this.isActive,
      targetAudience: targetAudience ?? this.targetAudience,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
