import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String farmerId;
  final String categoryId;
  final String categoryName;
  final String name;
  final String description;
  final double price;
  final String unit;
  final double quantity;
  final String? imageUrl;
  final List<String>? imageUrls;
  final bool isAvailable;
  final bool isOrganic;
  final String? farmerName;
  final String? marketName;
  final DateTime? createdAt;

  // New fields for Deals of the Day
  final double? originalPrice;
  final bool isDealOfTheDay;

  ProductModel({
    required this.id,
    required this.farmerId,
    required this.categoryId,
    this.categoryName = '',
    required this.name,
    required this.description,
    required this.price,
    required this.unit,
    required this.quantity,
    this.imageUrl,
    this.imageUrls,
    this.isAvailable = true,
    this.isOrganic = false,
    this.farmerName,
    this.marketName,
    this.createdAt,
    this.originalPrice,
    this.isDealOfTheDay = false,
  });

  factory ProductModel.fromMap(String id, Map<String, dynamic> map) {
    return ProductModel(
      id: id,
      farmerId: map['farmerId'] ?? map['Farmer_Id'] ?? '',
      categoryId: map['categoryId'] ?? map['Category_Id'] ?? '',
      categoryName: map['categoryName'] ?? '',
      name: map['name'] ?? map['Name'] ?? '',
      description: map['description'] ?? map['Description'] ?? '',
      price: (map['price'] ?? map['Price'] ?? 0).toDouble(),
      unit: map['unit'] ?? map['Unit'] ?? 'kg',
      quantity: (map['quantity'] ?? map['Quantity'] ?? 0).toDouble(),
      imageUrl: map['imageUrl'] ?? map['Image_Url'],
      imageUrls: map['imageUrls'] != null ? List<String>.from(map['imageUrls']) : null,
      isAvailable: map['isAvailable'] ?? map['Is_Available'] ?? true,
      isOrganic: map['isOrganic'] ?? map['Is_Organic'] ?? false,
      farmerName: map['farmerName'],
      marketName: map['marketName'],
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] is Timestamp
              ? (map['createdAt'] as Timestamp).toDate()
              : DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now())
          : null,
      originalPrice: map['originalPrice'] != null ? (map['originalPrice'] as num).toDouble() : null,
      isDealOfTheDay: map['isDealOfTheDay'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'farmerId': farmerId,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'name': name,
      'description': description,
      'price': price,
      'unit': unit,
      'quantity': quantity,
      'imageUrl': imageUrl,
      'imageUrls': imageUrls,
      'isAvailable': isAvailable,
      'isOrganic': isOrganic,
      'farmerName': farmerName,
      'marketName': marketName,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'originalPrice': originalPrice,
      'isDealOfTheDay': isDealOfTheDay,
    };
  }

  ProductModel copyWith({
    String? id,
    String? farmerId,
    String? categoryId,
    String? categoryName,
    String? name,
    String? description,
    double? price,
    String? unit,
    double? quantity,
    String? imageUrl,
    List<String>? imageUrls,
    bool? isAvailable,
    bool? isOrganic,
    String? farmerName,
    String? marketName,
    DateTime? createdAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      farmerId: farmerId ?? this.farmerId,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      unit: unit ?? this.unit,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl ?? this.imageUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      isAvailable: isAvailable ?? this.isAvailable,
      isOrganic: isOrganic ?? this.isOrganic,
      farmerName: farmerName ?? this.farmerName,
      marketName: marketName ?? this.marketName,

      createdAt: createdAt ?? this.createdAt,
    );
  }
}
