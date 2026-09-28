import re

with open('lib/screens/customer/customer_home_screen.dart', 'r', encoding='utf-8') as f:
    c = f.read()

old_add = '''  void _addToCart(Map<String, dynamic> product) {
    AuthInterceptor.executeAction(context, () {
      if (product['model'] != null) {
        Provider.of<CartProvider>(context, listen: false).addItem(product['model'] as ProductModel);
      }
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Added to Cart!')));
    });
  }'''

new_add = '''  void _addToCart(Map<String, dynamic> product) {
    AuthInterceptor.executeAction(context, () async {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && product['model'] != null) {
        final p = product['model'] as ProductModel;
        await DatabaseService().addToCart(
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Added to Cart!')));
    });
  }'''

c = c.replace(old_add, new_add)

with open('lib/screens/customer/customer_home_screen.dart', 'w', encoding='utf-8') as f:
    f.write(c)

print("Done")
