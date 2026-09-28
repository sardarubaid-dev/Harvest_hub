import re

with open('lib/screens/customer/cart_screen.dart', 'r', encoding='utf-8') as f:
    c = f.read()

# Fix 1: Named argument for streamPickupSlots
c = c.replace(
    '_slotsSub = _dbService.streamPickupSlots(markets.first.id).listen((slots) {',
    '_slotsSub = _dbService.streamPickupSlots(marketId: markets.first.id).listen((slots) {'
)

# Fix 2: Remove CartProvider and use local _itemsTotal for totalPayable
old_build_start = r'    final cartProvider = Provider\.of<CartProvider>\(context\);\s*final cartItems = cartProvider\.items\.values\.toList\(\);\s*final _itemsTotal = cartProvider\.totalAmount\.toInt\(\);\s*int totalPayable = _itemsTotal > 0\s*\?\s*_itemsTotal \+ 20\s*:\s*0;'
new_build_start = '''    int totalPayable = _itemsTotal;'''
c = re.sub(old_build_start, new_build_start, c, flags=re.DOTALL)

with open('lib/screens/customer/cart_screen.dart', 'w', encoding='utf-8') as f:
    f.write(c)

print("Done")
