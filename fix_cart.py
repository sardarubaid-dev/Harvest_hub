import re

file_path = 'lib/screens/customer/cart_screen.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace("item['name'] ?? 'Product'", "item['name'] ?? item['title'] ?? 'Product'")

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)
print("fixed cart screen")
