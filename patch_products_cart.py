with open('lib/screens/customer/products_screen.dart', 'r', encoding='utf-8') as f:
    c = f.read()

old_block = '''                                            AuthInterceptor.executeAction(context, () async {
                                              await _dbService.addToCart(
                                                uid: null,
                                                product: data,
                                                quantityDelta: 1,
                                              );
                                              if (!context.mounted) return;
                                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Added ${data['title']} to Cart!'),
                                                  duration: const Duration(seconds: 1),
                                                ),
                                              );
                                            });'''

new_block = '''                                            AuthInterceptor.executeAction(context, () async {
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
                                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Added ${data['title']} to Cart!'),
                                                  duration: const Duration(seconds: 1),
                                                ),
                                              );
                                            });'''

c = c.replace(old_block, new_block)
with open('lib/screens/customer/products_screen.dart', 'w', encoding='utf-8') as f:
    f.write(c)
print("Done")
