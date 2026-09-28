import re
file_path = 'lib/screens/customer/customer_home_screen.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

old_mapped = '''          'description': p.description,
        };
      }).toList();'''

new_mapped = '''          'description': p.description,
          'isDealOfTheDay': p.isDealOfTheDay,
          'originalPrice': p.originalPrice?.toStringAsFixed(0) ?? p.price.toStringAsFixed(0),
        };
      }).toList();'''
content = content.replace(old_mapped, new_mapped)

old_fresh = '''    setState(() {
      _freshProducts = mappedProducts;

      // Dynamically derive Recently Restocked from live in-stock Firestore products
      _recentlyRestocked = List.from(_freshProducts);
    });'''

new_fresh = '''    setState(() {
      _freshProducts = mappedProducts;

      // Dynamically derive Recently Restocked from live in-stock Firestore products
      _recentlyRestocked = List.from(_freshProducts);
      
      // Dynamically derive Deals of the Day
      _dealsOfTheDay = mappedProducts.where((p) => p['isDealOfTheDay'] == true).toList();
    });'''
content = content.replace(old_fresh, new_fresh)

# remove hardcoded deals list definition and replace with late list
old_deals_list = re.search(r'final List<Map<String, dynamic>> _dealsOfTheDay = \[.*?\n    \];', content, re.DOTALL)
if old_deals_list:
    content = content.replace(old_deals_list.group(0), 'List<Map<String, dynamic>> _dealsOfTheDay = [];')
else:
    print('regex failed to find _dealsOfTheDay')

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)
print('done')
