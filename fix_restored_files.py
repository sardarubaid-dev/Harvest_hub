with open('lib/screens/customer/cart_screen.dart', 'r', encoding='utf-8') as f:
    c = f.read()

import re

# Remove CartProvider override
c = re.sub(
    r'final cartProvider = Provider\.of<CartProvider>\(context\);\s*final cartItems = cartProvider\.items\.values\.toList\(\);\s*final _itemsTotal = cartProvider\.totalAmount\.toInt\(\);\s*int totalPayable = _itemsTotal;',
    'int totalPayable = _itemsTotal;',
    c,
    flags=re.DOTALL
)

# And make sure _itemsTotal is calculated correctly from _cartItems, NOT cartProvider
new_items_total = '''  int get _itemsTotal {
    int total = 0;
    for (var item in _cartItems) {
      double priceDouble = 0.0;
      if (item['price'] is num) {
        priceDouble = (item['price'] as num).toDouble();
      } else {
        priceDouble = double.tryParse(item['price']?.toString() ?? '0') ?? 0.0;
      }
      int price = priceDouble.toInt();
      int qty = (item['quantity'] is num) ? (item['quantity'] as num).toInt() : 1;
      total += (price * qty);
    }
    return total;
  }'''

c = re.sub(r'int get _itemsTotal \{.*?\n  \}', new_items_total, c, flags=re.DOTALL)

with open('lib/screens/customer/cart_screen.dart', 'w', encoding='utf-8') as f:
    f.write(c)

with open('lib/screens/customer/customer_home_screen.dart', 'r', encoding='utf-8') as f:
    c2 = f.read()

c2 = re.sub(r'void _addToCart\(Map<String, dynamic> product\) \{.*?\n  \}', '''void _addToCart(Map<String, dynamic> product) {
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
  }''', c2, flags=re.DOTALL)

with open('lib/screens/customer/customer_home_screen.dart', 'w', encoding='utf-8') as f:
    f.write(c2)

print("Done fixing restored files.")
