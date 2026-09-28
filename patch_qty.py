import re

file_path = r'lib\screens\customer\customer_home_screen.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

old_map = '''          'price': p.price.toStringAsFixed(0),
          'unit': '/ ',
          'stockBadge': '  available',
          'isFavorite': false,
          'imageColor': _getColorForCategory(p.categoryName),'''

new_map = '''          'price': p.price.toStringAsFixed(0),
          'unit': '/ ',
          'quantity': p.quantity,
          'stockBadge': '  available',
          'isFavorite': false,
          'imageColor': _getColorForCategory(p.categoryName),'''

if old_map in content:
    content = content.replace(old_map, new_map)
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    print("Patched successfully!")
else:
    print("Could not find the map block.")
