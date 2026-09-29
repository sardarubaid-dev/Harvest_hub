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
  final String? profileImageUrl;
  final double? latitude;
  final double? longitude;
  final bool isSuspended;
  final DateTime? createdAt;
  final List<String> verificationDocs;

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
    this.profileImageUrl,
    this.latitude,
    this.longitude,
    this.isSuspended = false,
    this.createdAt,
    this.verificationDocs = const [],
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
      profileImageUrl: map['profileImageUrl'] ?? map['ProfileImageUrl'],
      latitude: map['latitude'] != null ? (map['latitude'] as num).toDouble() : null,
      longitude: map['longitude'] != null ? (map['longitude'] as num).toDouble() : null,
      isSuspended: map['isSuspended'] ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString())
          : null,
      verificationDocs: map['verificationDocs'] != null
          ? List<String>.from(map['verificationDocs'])
          : (map['VerificationDocs'] != null ? List<String>.from(map['VerificationDocs']) : []),
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
      'profileImageUrl': profileImageUrl,
      'latitude': latitude,
      'longitude': longitude,
      'isSuspended': isSuspended,
      'createdAt':
          createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'verificationDocs': verificationDocs,
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
    String? profileImageUrl,
    double? latitude,
    double? longitude,
    bool? isSuspended,
    DateTime? createdAt,
    List<String>? verificationDocs,
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
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isSuspended: isSuspended ?? this.isSuspended,
      createdAt: createdAt ?? this.createdAt,
      verificationDocs: verificationDocs ?? this.verificationDocs,
    );
  }
}
