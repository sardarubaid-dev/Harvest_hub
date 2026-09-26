class CustomerModel {
  final String id;
  final String userId;
  final String name;
  final String email;
  final String phone;
  final String address;
  final List<String> wishlist;
  final List<String> followedFarmers;
  final DateTime? createdAt;

  CustomerModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    this.wishlist = const [],
    this.followedFarmers = const [],
    this.createdAt,
  });

  factory CustomerModel.fromMap(String id, Map<String, dynamic> map) {
    return CustomerModel(
      id: id,
      userId: map['userId'] ?? map['User_Id'] ?? id,
      name: map['name'] ?? map['Name'] ?? '',
      email: map['email'] ?? map['Email'] ?? '',
      phone: map['phone'] ?? map['Phone'] ?? '',
      address: map['address'] ?? map['Address'] ?? '',
      wishlist: List<String>.from(map['wishlist'] ?? []),
      followedFarmers: List<String>.from(map['followedFarmers'] ?? []),
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'wishlist': wishlist,
      'followedFarmers': followedFarmers,
      'createdAt': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  CustomerModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? email,
    String? phone,
    String? address,
    List<String>? wishlist,
    List<String>? followedFarmers,
    DateTime? createdAt,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      wishlist: wishlist ?? this.wishlist,
      followedFarmers: followedFarmers ?? this.followedFarmers,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
