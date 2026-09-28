class AppConfigModel {
  final double taxPercentage;
  final double platformFeePercentage;
  final double defaultDeliveryFee;
  final DateTime lastUpdated;

  AppConfigModel({
    this.taxPercentage = 0.0,
    this.platformFeePercentage = 0.0,
    this.defaultDeliveryFee = 0.0,
    required this.lastUpdated,
  });

  factory AppConfigModel.fromMap(Map<String, dynamic> map) {
    return AppConfigModel(
      taxPercentage: (map['taxPercentage'] ?? 0.0).toDouble(),
      platformFeePercentage: (map['platformFeePercentage'] ?? 0.0).toDouble(),
      defaultDeliveryFee: (map['defaultDeliveryFee'] ?? 0.0).toDouble(),
      lastUpdated: map['lastUpdated'] != null
          ? DateTime.parse(map['lastUpdated'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'taxPercentage': taxPercentage,
      'platformFeePercentage': platformFeePercentage,
      'defaultDeliveryFee': defaultDeliveryFee,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  AppConfigModel copyWith({
    double? taxPercentage,
    double? platformFeePercentage,
    double? defaultDeliveryFee,
    DateTime? lastUpdated,
  }) {
    return AppConfigModel(
      taxPercentage: taxPercentage ?? this.taxPercentage,
      platformFeePercentage: platformFeePercentage ?? this.platformFeePercentage,
      defaultDeliveryFee: defaultDeliveryFee ?? this.defaultDeliveryFee,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
