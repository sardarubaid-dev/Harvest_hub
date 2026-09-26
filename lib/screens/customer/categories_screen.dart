import 'package:flutter/material.dart';

import '../../core/dummy_data.dart';
import 'products_screen.dart';

class CategoriesScreen extends StatelessWidget {
  final Function(String) onCategorySelected;

  const CategoriesScreen({Key? key, required this.onCategorySelected})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF2E7D32);
    const Color darkText = Color(0xFF1F2937);
    const Color background = Color(0xFFF9FBF9);

    // Extracted categories from dummy data, excluding the "All" chip which is for the home filter
    final categories = DummyData.categories
        .where((c) => c['name'] != 'All')
        .toList();
    // Adding some more dummy categories to make the grid look full
    final allCategories = [
      ...categories,
      {'id': '6', 'name': 'Grains', 'icon': Icons.grass},
      {'id': '7', 'name': 'Herbs', 'icon': Icons.local_florist},
      {'id': '8', 'name': 'Organic', 'icon': Icons.compost},
      {'id': '9', 'name': 'Honey', 'icon': Icons.hive},
    ];

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 16.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'All Categories',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: darkText,
                    ),
                  ),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: primaryGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar (Optional for Categories)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: const [
                    Icon(Icons.search, color: Color(0xFF6B7280), size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Search categories...',
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Grid View
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 columns
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.9, // Adjust height-width ratio of cards
                ),
                itemCount: allCategories.length,
                itemBuilder: (context, index) {
                  final cat = allCategories[index];
                  // Alternating background colors for some visual flair similar to theme
                  final colors = [
                    const Color(0xFFE8F5E9), // Light Green
                    const Color(0xFFFFF3E0), // Light Orange
                    const Color(0xFFFFEBEE), // Light Red
                    const Color(0xFFE3F2FD), // Light Blue
                  ];
                  final bgColor = colors[index % colors.length];

                  return GestureDetector(
                    onTap: () {
                      onCategorySelected(cat['name'] as String);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: bgColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              cat['icon'] as IconData,
                              size: 40,
                              color: primaryGreen,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            cat['name'] as String,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: darkText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
