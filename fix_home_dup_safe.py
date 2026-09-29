with open('lib/screens/customer/customer_home_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

start_idx = content.find('SizedBox(\n          height: 110,\n          child: _categories.isEmpty')
end_idx = content.find('      ],\n    );\n  }', start_idx)

if start_idx != -1 and end_idx != -1:
    old_box = content[start_idx:end_idx]
    new_box = """SizedBox(
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
                  final cat = validCats[index];
                  
                  final colors = [
                    const Color(0xFFEFF7E3),
                    const Color(0xFFE8F4F9),
                    const Color(0xFFFCF1E6),
                    const Color(0xFFFDEDEC),
                    const Color(0xFFEFF6EA),
                    const Color(0xFFE8F7FC),
                    const Color(0xFFECF4F7),
                    const Color(0xFFFFF1E6),
                  ];
                  final bgColor = colors[index % colors.length];

                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedGlobalCategory = cat.name;
                          _currentIndex = 1; // Switch to Products tab
                        });
                      },
                      child: Container(
                        width: 80,
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              clipBehavior: Clip.hardEdge,
                              child: (cat.imageUrl != null && cat.imageUrl!.trim().isNotEmpty)
                                  ? Image.network(
                                      cat.imageUrl!.trim(),
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => const Icon(
                                        Icons.eco,
                                        color: Colors.green,
                                        size: 30,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.eco,
                                      color: Colors.green,
                                      size: 30,
                                    ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              cat.name,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                height: 1.1,
                                color: Color(0xFF374151),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),"""
    
    content = content[:start_idx] + new_box + content[end_idx:]
    with open('lib/screens/customer/customer_home_screen.dart', 'w', encoding='utf-8') as f:
        f.write(content)
    print("Fixed duplicates in home screen")
else:
    print("Block not found!")
