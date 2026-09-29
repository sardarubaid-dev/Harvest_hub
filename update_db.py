import re

with open('lib/services/database_service.dart', 'r', encoding='utf-8') as f:
    content = f.read()

old_func = """  Stream<List<ProductModel>> streamProductsByFarmer(String farmerId) {
    return _productsRef.where('farmerId', isEqualTo: farmerId).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs
          .map(
            (doc) => ProductModel.fromMap(
              doc.id,
              doc.data() as Map<String, dynamic>,
            ),
          )
          .toList();
    });
  }"""

new_func = """  Stream<List<ProductModel>> streamProductsByFarmer(String farmerId) {
    return _productsRef.where('farmerId', isEqualTo: farmerId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        try {
          return ProductModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
        } catch (e, stack) {
          print('Error mapping product ${doc.id}: $e');
          print(stack);
          return null;
        }
      }).whereType<ProductModel>().toList();
    });
  }"""

if old_func in content:
    content = content.replace(old_func, new_func)
    with open('lib/services/database_service.dart', 'w', encoding='utf-8') as f:
        f.write(content)
    print("Updated database service")
else:
    print("Could not find func")
