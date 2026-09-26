class CategoryModel {
  final String id;
  final String name;
  final String? imageUrl;

  CategoryModel({required this.id, required this.name, this.imageUrl});

  factory CategoryModel.fromMap(String id, Map<String, dynamic> map) {
    return CategoryModel(
      id: id,
      name: map['name'] ?? '',
      imageUrl: map['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'imageUrl': imageUrl};
  }
}
