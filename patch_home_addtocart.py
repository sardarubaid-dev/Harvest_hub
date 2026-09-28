with open('lib/screens/customer/customer_home_screen.dart', 'r', encoding='utf-8') as f:
    c = f.read()

old_add = '''  void _addToCart(Map<String, dynamic> product) {
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

new_add = '''  void _addToCart(Map<String, dynamic> product) {
    AuthInterceptor.executeAction(context, () async {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final unitStr = product['unit']?.toString().replaceAll('/ ', '') ?? 'unit';
        final priceRaw = product['price']?.toString() ?? '0';
        final doublePrice = double.tryParse(priceRaw) ?? 0.0;
        await DatabaseService().addToCart(
          uid: user.uid,
          product: {
            'id': product['id']?.toString() ?? '',
            'title': product['title']?.toString() ?? '',
            'price': doublePrice,
            'unit': unitStr,
            'imageUrl': product['imageUrl']?.toString() ?? '',
            'farmerName': product['farmerName']?.toString() ?? '',
            'farmerId': product['farmerId']?.toString() ?? '',
          },
          quantityDelta: 1,
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Added ${product['title'] ?? 'item'} to Cart!')));
    });
  }'''

c = c.replace(old_add, new_add)

with open('lib/screens/customer/customer_home_screen.dart', 'w', encoding='utf-8') as f:
    f.write(c)

print("Done with customer_home_screen add to cart")
