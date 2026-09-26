class FarmerModel {
  final String id;
  final String userId;
  final String farmName;
  final String description;
  final String location;
  final String contactNumber;
  final String? marketId;
  final double rating;
  final bool isApproved;
  final DateTime? createdAt;

  FarmerModel({
    required this.id,
    required this.userId,
    required this.farmName,
    required this.description,
    required this.location,
    required this.contactNumber,
    this.marketId,
    this.rating = 5.0,
    this.isApproved = true,
    this.createdAt,
  });

  factory FarmerModel.fromMap(String id, Map<String, dynamic> map) {
    return FarmerModel(
      id: id,
      userId: map['userId'] ?? map['User_Id'] ?? '',
      farmName:
          map['farmName'] ?? map['Business_Name'] ?? map['businessName'] ?? '',
      description: map['description'] ?? map['Description'] ?? '',
      location: map['location'] ?? map['Location'] ?? '',
      contactNumber:
          map['contactNumber'] ?? map['ContactNumber'] ?? map['phone'] ?? '',
      marketId: map['marketId'] ?? map['Market_Id'],
      rating: (map['rating'] ?? map['Rating'] ?? 5.0).toDouble(),
      isApproved: map['isApproved'] ?? map['IsApproved'] ?? true,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'farmName': farmName,
      'businessName': farmName,
      'description': description,
      'location': location,
      'contactNumber': contactNumber,
      'marketId': marketId,
      'rating': rating,
      'isApproved': isApproved,
      'createdAt':
          createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  FarmerModel copyWith({
    String? id,
    String? userId,
    String? farmName,
    String? description,
    String? location,
    String? contactNumber,
    String? marketId,
    double? rating,
    bool? isApproved,
    DateTime? createdAt,
  }) {
    return FarmerModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      farmName: farmName ?? this.farmName,
      description: description ?? this.description,
      location: location ?? this.location,
      contactNumber: contactNumber ?? this.contactNumber,
      marketId: marketId ?? this.marketId,
      rating: rating ?? this.rating,
      isApproved: isApproved ?? this.isApproved,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
