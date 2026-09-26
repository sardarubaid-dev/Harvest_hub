class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role;
  final String? phone;
  final String? photoUrl;
  final String? address;
  final bool isActive;
  final DateTime? createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.photoUrl,
    this.address,
    this.isActive = true,
    this.createdAt,
  });

  bool get isCustomer => role.toLowerCase() == 'customer';
  bool get isFarmer => role.toLowerCase() == 'farmer';
  bool get isAdmin => role.toLowerCase() == 'admin';

  factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
    return UserModel(
      uid: uid,
      name: map['name'] ?? map['Name'] ?? '',
      email: map['email'] ?? map['Email'] ?? '',
      role: map['role'] ?? map['Role'] ?? 'Customer',
      phone: map['phone'] ?? map['Phone'],
      photoUrl: map['photoUrl'] ?? map['PhotoUrl'],
      address: map['address'] ?? map['Address'],
      isActive: map['isActive'] ?? map['IsActive'] ?? true,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'role': role,
      'phone': phone,
      'photoUrl': photoUrl,
      'address': address,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? role,
    String? phone,
    String? photoUrl,
    String? address,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      address: address ?? this.address,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}