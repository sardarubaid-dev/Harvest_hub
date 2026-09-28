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
  final double averageRating;
  final int totalReviews;
  final Map<String, int> ratingBreakdown;

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
    required this.isAvailable,
    this.isOrganic = false,
    this.farmerName,
    this.marketName,
    this.createdAt,
    this.averageRating = 0.0,
    this.totalReviews = 0,
    this.ratingBreakdown = const {'5': 0, '4': 0, '3': 0, '2': 0, '1': 0},
  });

  factory ProductModel.fromMap(String id, Map<String, dynamic> map) {
    return ProductModel(
      id: id,
      farmerId: map['farmerId'] ?? map['Farmer_Id'] ?? '',
      categoryId:
          map['categoryId'] ??
          map['Category_Id'] ??
          map['category'] ??
          map['Category'] ??
          '',
      categoryName: map['categoryName'] ?? map['Category'] ?? '',
      name: map['name'] ?? map['Item_Name'] ?? map['itemName'] ?? '',
      description: map['description'] ?? map['Description'] ?? '',
      price: (map['price'] ?? map['Price_Per_Unit'] ?? map['pricePerUnit'] ?? 0)
          .toDouble(),
      unit: map['unit'] ?? map['Unit'] ?? 'kg',
      quantity: (map['quantity'] ?? map['Stock_Qty'] ?? map['stockQty'] ?? 0)
          .toDouble(),
      imageUrl: map['imageUrl'] ?? map['Image_Url'],
      imageUrls: map['imageUrls'] != null 
          ? (map['imageUrls'] as List).where((e) => e != null).map((e) => e.toString()).toList()
          : (map['imageUrl'] != null ? [map['imageUrl'].toString()] : null),
      isAvailable:
          map['isAvailable'] ??
          ((map['quantity'] ?? map['Stock_Qty'] ?? 0) > 0),
      isOrganic: map['isOrganic'] ?? false,
      farmerName: map['farmerName'] ?? map['Farmer_Name'],
      marketName: map['marketName'] ?? map['Market_Name'],
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString())
          : null,
      averageRating: (map['averageRating'] ?? 0.0).toDouble(),
      totalReviews: (map['totalReviews'] ?? 0).toInt(),
      ratingBreakdown: map['ratingBreakdown'] != null 
          ? Map<String, int>.from(map['ratingBreakdown'])
          : {'5': 0, '4': 0, '3': 0, '2': 0, '1': 0},
    );
  }



  Map<String, dynamic> toMap() {
    return {
      'farmerId': farmerId,
      'Farmer_Id': farmerId,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'Category': categoryName.isNotEmpty ? categoryName : categoryId,
      'name': name,
      'Item_Name': name,
      'description': description,
      'price': price,
      'Price_Per_Unit': price,
      'unit': unit,
      'quantity': quantity,
      'Stock_Qty': quantity,
      'imageUrl': imageUrl,
      'Image_Url': imageUrl,
      'imageUrls': imageUrls,
      'isAvailable': isAvailable && quantity > 0,
      'isOrganic': isOrganic,
      'farmerName': farmerName,
      'marketName': marketName,
      'createdAt':
          createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'ratingBreakdown': ratingBreakdown,
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
    double? averageRating,
    int? totalReviews,
    Map<String, int>? ratingBreakdown,
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
      averageRating: averageRating ?? this.averageRating,
      totalReviews: totalReviews ?? this.totalReviews,
      ratingBreakdown: ratingBreakdown ?? this.ratingBreakdown,
    );
  }
}
