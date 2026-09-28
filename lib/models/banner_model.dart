class BannerModel {
  final String id;
  final String title;
  final String imageUrl;
  final String linkType; // 'category', 'farmer', 'product', 'none'
  final String? linkTarget;
  final int durationSeconds;
  final bool isActive;
  final DateTime createdAt;

  BannerModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.linkType = 'none',
    this.linkTarget,
    this.durationSeconds = 5,
    this.isActive = true,
    required this.createdAt,
  });

  factory BannerModel.fromMap(String id, Map<String, dynamic> map) {
    return BannerModel(
      id: id,
      title: map['title'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      linkType: map['linkType'] ?? 'none',
      linkTarget: map['linkTarget'],
      durationSeconds: map['durationSeconds'] ?? 5,
      isActive: map['isActive'] ?? true,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'imageUrl': imageUrl,
      'linkType': linkType,
      'linkTarget': linkTarget,
      'durationSeconds': durationSeconds,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  BannerModel copyWith({
    String? id,
    String? title,
    String? imageUrl,
    String? linkType,
    String? linkTarget,
    int? durationSeconds,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return BannerModel(
      id: id ?? this.id,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      linkType: linkType ?? this.linkType,
      linkTarget: linkTarget ?? this.linkTarget,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
