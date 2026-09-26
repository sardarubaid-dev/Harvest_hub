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
  final bool isAvailable;
  final String? farmerName;
  final DateTime? createdAt;

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
    required this.isAvailable,
    this.farmerName,
    this.createdAt,
  });

  factory ProductModel.fromMap(String id, Map<String, dynamic> map) {
    return ProductModel(
      id: id,
      farmerId: map['farmerId'] ?? map['Farmer_Id'] ?? '',
      categoryId: map['categoryId'] ?? map['Category_Id'] ?? map['category'] ?? map['Category'] ?? '',
      categoryName: map['categoryName'] ?? map['Category'] ?? '',
      name: map['name'] ?? map['Item_Name'] ?? map['itemName'] ?? '',
      description: map['description'] ?? map['Description'] ?? '',
      price: (map['price'] ?? map['Price_Per_Unit'] ?? map['pricePerUnit'] ?? 0).toDouble(),
      unit: map['unit'] ?? map['Unit'] ?? 'kg',
      quantity: (map['quantity'] ?? map['Stock_Qty'] ?? map['stockQty'] ?? 0).toDouble(),
      imageUrl: map['imageUrl'] ?? map['Image_Url'],
      isAvailable: map['isAvailable'] ?? ((map['quantity'] ?? map['Stock_Qty'] ?? 0) > 0),
      farmerName: map['farmerName'] ?? map['Farmer_Name'],
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString())
          : null,
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
      'isAvailable': isAvailable && quantity > 0,
      'farmerName': farmerName,
      'createdAt': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
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
    bool? isAvailable,
    String? farmerName,
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
      isAvailable: isAvailable ?? this.isAvailable,
      farmerName: farmerName ?? this.farmerName,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}