import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/auth_interceptor.dart';

import '../../models/category_model.dart';
import '../../models/product_model.dart';
import '../../services/database_service.dart';
import '../../providers/cart_provider.dart';
import '../../providers/wishlist_provider.dart';
import 'package:provider/provider.dart';
import 'product_detail_screen.dart';
import '../shared/product_card_widget.dart';

class ProductsScreen extends StatefulWidget {
  final String? initialCategory;

  const ProductsScreen({Key? key, this.initialCategory}) : super(key: key);

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  late String _selectedCategory;
  final DatabaseService _dbService = DatabaseService();

  late Stream<List<CategoryModel>> _categoriesStream;
  late Stream<List<ProductModel>> _productsStream;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory ?? 'All';
    _categoriesStream = _dbService.streamCategories();
    _productsStream = _dbService.streamAllProducts();
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

    return StreamBuilder<List<CategoryModel>>(
      stream: _categoriesStream,
      builder: (context, catSnapshot) {
        final categories = [
          'All',
          if (catSnapshot.hasData)
            ...catSnapshot.data!
                .where((c) => c.name != 'All')
                .map((c) => c.name),
        ];

        return StreamBuilder<List<ProductModel>>(
          stream: _productsStream,
          builder: (context, snapshot) {
            List<Map<String, dynamic>> products = [];

            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              products = snapshot.data!.map((p) {
                return {
                  'productModel': p,
                  'id': p.id,
                  'title': p.name,
                  'category': p.categoryName.isNotEmpty
                      ? p.categoryName.toUpperCase()
                      : 'PRODUCE',
                  'farmerName': p.farmerName ?? 'Green Valley Farm',
                  'price': p.price.toStringAsFixed(0),
                  'unit': '/ ${p.unit}',
                  'stockBadge': '${p.quantity.toInt()} ${p.unit} available',
                  'isFavorite': false,
                  'imageColor': const Color(0xFFA5D6A7),
                  'imageUrl': p.imageUrl ?? '',
                  'description': p.description,
                };
              }).toList();
            }

            if (_selectedCategory != 'All') {
              products = products.where((p) {
                return p['category'].toString().toLowerCase().contains(
                      _selectedCategory.toLowerCase(),
                    );
              }).toList();
            }

    return Scaffold(
      backgroundColor: background,
      body: Column(
        children: [
          
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
                      childAspectRatio: 0.65,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                        final data = products[index];
                        return ProductCard(data: data);
                    },
                  ),
          ),
        ],
      ),
    );
          },
        );
      },
    );
  }
}
