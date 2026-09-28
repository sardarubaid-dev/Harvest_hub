import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/product_model.dart';
import '../../services/database_service.dart';
import 'product_detail_screen.dart';

class SearchFilterScreen extends StatefulWidget {
  final String? initialQuery;
  const SearchFilterScreen({Key? key, this.initialQuery}) : super(key: key);

  @override
  State<SearchFilterScreen> createState() => _SearchFilterScreenState();
}

class _SearchFilterScreenState extends State<SearchFilterScreen> {
  final DatabaseService _dbService = DatabaseService();
  final TextEditingController _searchController = TextEditingController();

  late Stream<List<ProductModel>> _productsStream;
  List<ProductModel> _allProducts = [];
  List<ProductModel> _filtered = [];

  String _selectedCategory = 'All';
  String _sortBy = 'Name';
  bool _isLoading = true;

  final List<String> _categories = [
    'All', 'Fruits', 'Vegetables', 'Grains', 'Dairy', 'Herbs', 'Organic'
  ];

  final List<String> _sortOptions = ['Name', 'Price: Low to High', 'Price: High to Low'];

  @override
  void initState() {
    super.initState();
    _productsStream = _dbService.streamAllProducts();
    _productsStream.listen((products) {
      if (mounted) {
        setState(() {
          _allProducts = products;
          _applyFilters();
          _isLoading = false;
        });
      }
    });
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final q = _searchController.text.trim().toLowerCase();
    List<ProductModel> result = _allProducts;

    // Search filter
    if (q.isNotEmpty) {
      result = result.where((p) {
        final matchesName = p.name.toLowerCase().contains(q);
        final matchesDesc = (p.description ?? '').toLowerCase().contains(q);
        final matchesFarmer = (p.farmerName ?? '').toLowerCase().contains(q);
        final matchesCat = p.categoryName.toLowerCase().contains(q);
        final matchesMarket = (p.marketName ?? '').toLowerCase().contains(q);
        return matchesName || matchesDesc || matchesFarmer || matchesCat || matchesMarket;
      }).toList();
    }

    // Category filter
    if (_selectedCategory != 'All') {
      result = result
          .where((p) => p.categoryName.toLowerCase().contains(_selectedCategory.toLowerCase()))
          .toList();
    }

    // Sort
    if (_sortBy == 'Name') {
      result.sort((a, b) => a.name.compareTo(b.name));
    } else if (_sortBy == 'Price: Low to High') {
      result.sort((a, b) => a.price.compareTo(b.price));
    } else if (_sortBy == 'Price: High to Low') {
      result.sort((a, b) => b.price.compareTo(a.price));
    }

    setState(() {
      _filtered = result;
    });
  }

  void _addToCart(ProductModel p) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to add to cart')),
      );
      return;
    }
    await _dbService.addToCart(
      uid: uid,
      product: {
        'id': p.id,
        'title': p.name,
        'price': p.price,
        'unit': p.unit,
        'imageUrl': p.imageUrl ?? '',
        'farmerName': p.farmerName ?? '',
        'farmerId': p.farmerId,
      },
      quantityDelta: 1,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${p.name} added to cart')),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF2E7D32);
    const Color darkText = Color(0xFF1F2937);
    const Color background = Color(0xFFF9FBF9);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'Search Products',
          style: TextStyle(color: darkText, fontWeight: FontWeight.bold),
        ),
        foregroundColor: darkText,
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, category, farmer...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF6B7280)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _applyFilters();
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFFF9FBF9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          // Category chips + sort
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              children: [
                // Category chips
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final cat = _categories[index];
                      final isSelected = _selectedCategory == cat;
                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedCategory = cat);
                          _applyFilters();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? primaryGreen : const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            cat,
                            style: TextStyle(
                              color: isSelected ? Colors.white : const Color(0xFF6B7280),
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                // Sort row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Text('Sort:', style: TextStyle(color: Color(0xFF6B7280), fontSize: 13)),
                      const SizedBox(width: 8),
                      DropdownButton<String>(
                        value: _sortBy,
                        isDense: true,
                        underline: const SizedBox(),
                        items: _sortOptions.map((o) => DropdownMenuItem(value: o, child: Text(o, style: const TextStyle(fontSize: 13)))).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _sortBy = val);
                            _applyFilters();
                          }
                        },
                      ),
                      const Spacer(),
                      Text(
                        '${_filtered.length} results',
                        style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Results
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            const Text(
                              'No products found',
                              style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.65,
                        ),
                        itemCount: _filtered.length,
                        itemBuilder: (context, index) {
                          final p = _filtered[index];
                          return GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProductDetailScreen(product: {
                                  'id': p.id,
                                  'title': p.name,
                                  'category': p.categoryName,
                                  'farmerName': p.farmerName ?? '',
                                  'farmerId': p.farmerId,
                                  'price': p.price.toStringAsFixed(0),
                                  'unit': p.unit,
                                  'imageUrl': p.imageUrl ?? '',
                                  'description': p.description,
                                  'model': p,
                                }),
                              ),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Image
                                  Container(
                                    height: 120,
                                    decoration: BoxDecoration(
                                      color: Colors.green[50],
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
                                      child: (p.imageUrl != null && p.imageUrl!.isNotEmpty)
                                          ? Image.network(
                                              p.imageUrl!,
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              errorBuilder: (_, __, ___) => const Center(
                                                child: Icon(Icons.image, color: Colors.grey, size: 40),
                                              ),
                                            )
                                          : const Center(
                                              child: Icon(Icons.image, color: Colors.grey, size: 40),
                                            ),
                                    ),
                                  ),
                                  // Info
                                  Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          p.categoryName,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Color(0xFF6B7280),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          p.name,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: darkText,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          p.farmerName ?? '',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF6B7280),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Rs. ${p.price.toStringAsFixed(0)}',
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: darkText,
                                                  ),
                                                ),
                                                Text(
                                                  '/ ${p.unit}',
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    color: Color(0xFF6B7280),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            GestureDetector(
                                              onTap: () => _addToCart(p),
                                              child: Container(
                                                padding: const EdgeInsets.all(6),
                                                decoration: const BoxDecoration(
                                                  color: primaryGreen,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.add,
                                                  color: Colors.white,
                                                  size: 16,
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
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}