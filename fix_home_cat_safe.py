with open('lib/screens/customer/customer_home_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

start_idx = content.find('Widget _buildCategoriesShowcase(')
end_idx = content.find('Widget _buildCustomerReviewsSection(', start_idx)

if start_idx != -1 and end_idx != -1:
    new_method = """Widget _buildCategoriesShowcase(
    Color primaryGreen,
    Color darkText,
    Color greyText,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Shop by Category',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: darkText,
                ),
              ),
              InkWell(
                onTap: () {
                  setState(() => _currentIndex = 2); // Switch to Categories tab
                },
                child: Row(
                  children: [
                    Text(
                      'View All',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: primaryGreen,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward, color: primaryGreen, size: 13),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 110,
          child: _categories.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _categories.where((c) => c.name != 'All').length,
                  itemBuilder: (context, index) {
                    final validCats = _categories.where((c) => c.name != 'All').toList();
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
                ),
        ),
      ],
    );
  }

  """
    
    content = content[:start_idx] + new_method + content[end_idx:]
    with open('lib/screens/customer/customer_home_screen.dart', 'w', encoding='utf-8') as f:
        f.write(content)
    print("Updated home screen categories safely")
else:
    print("Could not find block boundaries")
