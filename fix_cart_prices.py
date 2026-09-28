import re

with open('lib/screens/customer/cart_screen.dart', 'r', encoding='utf-8') as f:
    c = f.read()

# Fix 1: _itemsTotal
old_items_total = r'''  int get _itemsTotal {
    int total = 0;
    for (var item in _cartItems) {
      double priceDouble = 0.0;
      if (item\['price'\] is num) {
        priceDouble = \(item\['price'\] as num\)\.toDouble\(\);
      } else {
        priceDouble = double\.tryParse\(item\['price'\]\?\.toString\(\) \?\? '0'\) \?\? 0\.0;
      }
      int price = priceDouble\.toInt\(\);
      int qty = \(item\['quantity'\] is num\) \? \(item\['quantity'\] as num\)\.toInt\(\) : 1;
      total \+= \(price \* qty\);
    }
    return total;
  }'''

new_items_total = '''  int get _itemsTotal {
    int total = 0;
    for (var item in _cartItems) {
      double priceDouble = double.tryParse(item['price']?.toString().replaceAll(RegExp(r'[^0-9.]'), '') ?? '0') ?? 0.0;
      int price = priceDouble.toInt();
      int qty = (item['quantity'] is num) ? (item['quantity'] as num).toInt() : 1;
      total += (price * qty);
    }
    return total;
  }'''
c = re.sub(old_items_total, new_items_total, c, flags=re.DOTALL)

# Fix 2: unitPrice
c = re.sub(
    r"final int unitPrice =\s*int\.tryParse\(item\['price'\]\.toString\(\)\) \?\? 0;",
    r"final int unitPrice = (double.tryParse(item['price']?.toString().replaceAll(RegExp(r'[^0-9.]'), '') ?? '0') ?? 0.0).toInt();",
    c
)

with open('lib/screens/customer/cart_screen.dart', 'w', encoding='utf-8') as f:
    f.write(c)
