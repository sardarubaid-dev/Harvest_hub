class CategoryModel {
  final String id;
  final String name;
  final String? imageUrl;
  final String? iconName;
  final String? itemCount;

  CategoryModel({
    required this.id,
    required this.name,
    this.imageUrl,
    this.iconName,
    this.itemCount,
  });

  factory CategoryModel.fromMap(String id, Map<String, dynamic> map) {
    return CategoryModel(
      id: id,
      name: map['name'] ?? '',
      imageUrl: map['imageUrl'],
      iconName: map['iconName'],
      itemCount: map['itemCount'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'iconName': iconName,
      'itemCount': itemCount,
    };
  }

  CategoryModel copyWith({
    String? id,
    String? name,
    String? imageUrl,
    String? iconName,
    String? itemCount,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      iconName: iconName ?? this.iconName,
      itemCount: itemCount ?? this.itemCount,
    );
  }
}
