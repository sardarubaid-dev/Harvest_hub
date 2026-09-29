with open('lib/screens/customer/categories_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

old_block = """                  final allCategories = snapshot.data!
                      .where((c) => c.name != 'All')
                      .toList();"""

new_block = """                  final rawCategories = snapshot.data!
                      .where((c) => c.name != 'All')
                      .toList();
                  final uniqueMap = <String, CategoryModel>{};
                  for (var c in rawCategories) {
                    if (!uniqueMap.containsKey(c.name)) {
                      uniqueMap[c.name] = c;
                    }
                  }
                  final allCategories = uniqueMap.values.toList();"""

if old_block in content:
    content = content.replace(old_block, new_block)
    with open('lib/screens/customer/categories_screen.dart', 'w', encoding='utf-8') as f:
        f.write(content)
    print("Updated categories_screen.dart to remove duplicates")
else:
    print("Block not found in categories_screen")
