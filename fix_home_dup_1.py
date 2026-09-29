with open('lib/screens/customer/customer_home_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

old_block = """        SizedBox(
          height: 110,
          child: _categories.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _categories.where((c) => c.name != 'All').length,
                  itemBuilder: (context, index) {
                    final validCats = _categories.where((c) => c.name != 'All').toList();
                    final cat = validCats[index];"""

new_block = """        SizedBox(
          height: 110,
          child: Builder(
            builder: (context) {
              if (_categories.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              final rawCats = _categories.where((c) => c.name != 'All').toList();
              final uniqueMap = <String, CategoryModel>{};
              for (var c in rawCats) {
                if (!uniqueMap.containsKey(c.name)) {
                  uniqueMap[c.name] = c;
                }
              }
              final validCats = uniqueMap.values.toList();

              return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: validCats.length,
                  itemBuilder: (context, index) {
                    final cat = validCats[index];"""

if old_block in content:
    content = content.replace(old_block, new_block)
    # also add closing braces for the Builder
    # wait, the original has `}, \n                ),\n        ),`
    # Let me just replace the entire SizedBox
