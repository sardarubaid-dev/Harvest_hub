import re

# Fix category_products_screen.dart
with open('lib/screens/customer/category_products_screen.dart', 'r', encoding='utf-8') as f:
    c = f.read()

c = c.replace(
    "Provider.of<CartProvider>(context, listen: false).addItem(data['productModel'] as ProductModel);",
    '''final user = FirebaseAuth.instance.currentUser;
                                                if (user != null) {
                                                  final p = data['productModel'] as ProductModel;
                                                  DatabaseService().addToCart(
                                                    uid: user.uid,
                                                    product: {
                                                      'id': p.id,
                                                      'title': p.name,
                                                      'price': p.price,
                                                      'unit': p.unit,
                                                      'imageUrl': p.imageUrl ?? '',
                                                      'farmerName': p.farmerName ?? '',
                                                      'farmerId': p.farmerId,
                                                    },
                                                    quantityDelta: 1,
                                                  );
                                                }'''
)

with open('lib/screens/customer/category_products_screen.dart', 'w', encoding='utf-8') as f:
    f.write(c)


# Fix products_screen.dart
with open('lib/screens/customer/products_screen.dart', 'r', encoding='utf-8') as f:
    p_content = f.read()

p_content = p_content.replace(
    '''                                              AuthInterceptor.executeAction(context, () async {
                                                await _dbService.addToCart(
                                                  uid: null,
                                                  product: data,
                                                  quantityDelta: 1,
                                                );
                                                if (!context.mounted) return;
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text('Added ${data['title']} to Cart!'),
                                                    duration: const Duration(seconds: 1),
                                                  ),
                                                );
                                              });''',
    '''                                              AuthInterceptor.executeAction(context, () async {
                                                final user = FirebaseAuth.instance.currentUser;
                                                if (user != null) {
                                                  final p = data['productModel'] as ProductModel;
                                                  await _dbService.addToCart(
                                                    uid: user.uid,
                                                    product: {
                                                      'id': p.id,
                                                      'title': p.name,
                                                      'price': p.price,
                                                      'unit': p.unit,
                                                      'imageUrl': p.imageUrl ?? '',
                                                      'farmerName': p.farmerName ?? '',
                                                      'farmerId': p.farmerId,
                                                    },
                                                    quantityDelta: 1,
                                                  );
                                                }
                                                if (!context.mounted) return;
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text('Added ${data['title']} to Cart!'),
                                                    duration: const Duration(seconds: 1),
                                                  ),
                                                );
                                              });'''
)

with open('lib/screens/customer/products_screen.dart', 'w', encoding='utf-8') as f:
    f.write(p_content)

print("Done")
