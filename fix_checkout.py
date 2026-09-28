import re

file_path = 'lib/screens/customer/checkout_screen.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

old_map = """        return OrderItem(
          productId: item['productId'] ?? '',
          farmerId: item['farmerId'] ?? '',
          productName: item['name'] ?? 'Unknown Item',
          price: price,
          quantity: qty,
          unit: item['unit'] ?? 'kg',
          imageUrl: item['imageUrl'],
        );"""

new_map = """        return OrderItem(
          productId: item['productId'] ?? item['id'] ?? '',
          farmerId: item['farmerId'] ?? '',
          productName: item['name'] ?? item['title'] ?? 'Unknown Item',
          price: price,
          quantity: qty,
          unit: item['unit'] ?? 'kg',
          imageUrl: item['imageUrl'],
        );"""
content = content.replace(old_map, new_map)

# Also fix the order details mapping below to show name properly
old_name = "Text(item['name'] ?? 'Item'"
new_name = "Text(item['name'] ?? item['title'] ?? 'Item'"
content = content.replace(old_name, new_name)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)
print("fixed")
