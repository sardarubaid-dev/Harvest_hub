import 'package:flutter/material.dart';
import '../../core/auth_interceptor.dart';

import '../../core/dummy_data.dart';
import 'product_detail_screen.dart';

class ProductsScreen extends StatefulWidget {
  final String? initialCategory;

  const ProductsScreen({Key? key, this.initialCategory}) : super(key: key);

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory ?? 'All';
  }

  @override
  void didUpdateWidget(covariant ProductsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialCategory != oldWidget.initialCategory) {
      setState(() {
        _selectedCategory = widget.initialCategory ?? 'All';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF2E7D32);
    const Color darkText = Color(0xFF1F2937);
    const Color greyText = Color(0xFF6B7280);
    const Color background = Color(0xFFF9FBF9);

    // List of categories for the filter row
    final categories = [
      'All',
      ...DummyData.categories
          .where((c) => c['name'] != 'All')
          .map((c) => c['name'].toString()),
    ];

    // Filter products based on selected category
    List<Map<String, dynamic>> products = DummyData.freshProducts;
    if (_selectedCategory != 'All') {
      products = products.where((p) {
        return p['category'].toString().toLowerCase() ==
            _selectedCategory.toLowerCase();
      }).toList();
    }

    return Scaffold(
      backgroundColor: background,
      body: Column(
        children: [
          // Filter Row
          Container(
            height: 60,
            color: Colors.white,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = cat;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? primaryGreen : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : const Color(0xFFE5E7EB),
                        ),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          color: isSelected ? Colors.white : darkText,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Products Grid
          Expanded(
            child: products.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No products found in $_selectedCategory',
                          style: const TextStyle(fontSize: 16, color: greyText),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16.0),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final data = products[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailScreen(product: data),
                            ),
                          );
                        },
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Stack(
                                children: [
                                  Container(
                                    height: 120,
                                    decoration: BoxDecoration(
                                      color: data['imageColor'],
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(16),
                                        topRight: Radius.circular(16),
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(16),
                                        topRight: Radius.circular(16),
                                      ),
                                      child: (data['imageUrl'] != null && data['imageUrl'].toString().isNotEmpty)
                                          ? Image.network(
                                              data['imageUrl'],
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              height: double.infinity,
                                            )
                                          : Center(
                                              child: Icon(
                                                Icons.image,
                                                size: 40,
                                                color: Colors.black.withOpacity(0.2),
                                              ),
                                            ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: GestureDetector(
                                      onTap: () {
                                        AuthInterceptor.executeAction(context, () {
                                          // Handle favorite tap
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          data['isFavorite'] == true ? Icons.favorite : Icons.favorite_border,
                                          size: 16,
                                          color: data['isFavorite'] == true ? Colors.red : const Color(0xFF6B7280),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 8,
                                    left: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const CircleAvatar(
                                            radius: 3,
                                            backgroundColor: Color(0xFF2E7D32),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            data['stockBadge'],
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF2E7D32),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data['category'],
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF6B7280),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      data['title'],
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1F2937),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            data['farmerName'],
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF4B5563),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(
                                          Icons.verified,
                                          size: 12,
                                          color: Color(0xFF2E7D32),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Price',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Color(0xFF6B7280),
                                              ),
                                            ),
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  'Rs. ',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF1F2937),
                                                  ),
                                                ),
                                                Text(
                                                  data['unit'],
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    color: Color(0xFF6B7280),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            AuthInterceptor.executeAction(context, () {
                                              // Implement add to cart
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: const BoxDecoration(
                                              color: Color(0xFF2E7D32),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.add,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ));
                    },
                  ),
          ),
        ],
      ),
    );
  }
}