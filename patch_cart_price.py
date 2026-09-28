with open('lib/screens/customer/cart_screen.dart', 'r', encoding='utf-8') as f:
    c = f.read()

# Fix _itemsTotal
old_items_total = '''  int get _itemsTotal {
    int total = 0;
    for (var item in _cartItems) {
      int price = int.tryParse(
            item['price'].toString().replaceAll(RegExp(r'[^0-9]'), ''),
          ) ??
          0;
      int qty = (item['quantity'] is num) ? (item['quantity'] as num).toInt() : 1;
      total += (price * qty);
    }
    return total;
  }'''

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

c = c.replace(old_items_total, new_items_total)

# Fix unitPrice inside build
old_unit_price = '''                            final int unitPrice =
                                int.tryParse(item['price'].toString()) ?? 0;'''

new_unit_price = '''                            double rawPrice = 0.0;
                            if (item['price'] is num) {
                              rawPrice = (item['price'] as num).toDouble();
                            } else {
                              rawPrice = double.tryParse(item['price']?.toString() ?? '0') ?? 0.0;
                            }
                            final int unitPrice = rawPrice.toInt();'''

c = c.replace(old_unit_price, new_unit_price)

with open('lib/screens/customer/cart_screen.dart', 'w', encoding='utf-8') as f:
    f.write(c)

print("Done with cart_screen price fix")
