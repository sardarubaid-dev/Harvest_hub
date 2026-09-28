import re
file_path = 'lib/screens/customer/customer_home_screen.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

old_logic = '''    final String selectedCategoryName = _selectedCategoryId == '1'
        ? ''
        : _categories
            .firstWhere(
              (c) => c.id == _selectedCategoryId,
              orElse: () => CategoryModel(id: '', name: ''),
            )
            .name
            .toLowerCase();

    final List<Map<String, dynamic>> filteredProducts = _freshProducts.where((p) {
      if (_selectedCategoryId == '1') return true;
      return p['category'].toString().toLowerCase() == selectedCategoryName;
    }).toList();'''

new_logic = '''    final List<Map<String, dynamic>> availableProducts = _freshProducts.where((p) => (p['quantity'] ?? 0) > 0).toList();
    final Set<String> validCategoryNames = availableProducts.map((p) => p['category'].toString().toLowerCase()).toSet();
    final Set<String> _seenNames = {};
    final List<CategoryModel> displayCategories = _categories.where((cat) {
      final n = cat.name.toLowerCase();
      if (n == 'all') return false;
      if (!validCategoryNames.contains(n)) return false;
      if (_seenNames.contains(n)) return false;
      _seenNames.add(n);
      return true;
    }).toList();

    final String selectedCategoryName = _selectedCategoryId == '1'
        ? ''
        : displayCategories
            .firstWhere(
              (c) => c.id == _selectedCategoryId,
              orElse: () => CategoryModel(id: '', name: ''),
            )
            .name
            .toLowerCase();

    final List<Map<String, dynamic>> filteredProducts = availableProducts.where((p) {
      if (_selectedCategoryId == '1') return true;
      return p['category'].toString().toLowerCase() == selectedCategoryName;
    }).toList();'''

content = content.replace(old_logic, new_logic)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)
print("done")
