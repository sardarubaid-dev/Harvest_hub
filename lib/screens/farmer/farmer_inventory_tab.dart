import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../theme/app_theme.dart';
import 'add_product_screen.dart';
import 'edit_product_screen.dart';
import 'farmer_categories_screen.dart';
import 'farmer_product_detail_screen.dart';

class FarmerInventoryTab extends StatefulWidget {
  const FarmerInventoryTab({super.key});

  @override
  State<FarmerInventoryTab> createState() => _FarmerInventoryTabState();
}

class _FarmerInventoryTabState extends State<FarmerInventoryTab> {
  final DatabaseService _dbService = DatabaseService();
  final TextEditingController _searchCtrl = TextEditingController();

  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedStockStatus = 'All'; 

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _openAddProduct() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddProductScreen()),
    );
  }

  void _openCategoriesScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FarmerCategoriesScreen(isSelectionMode: false),
      ),
    );
  }

  void _openProductDetails(ProductModel product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FarmerProductDetailScreen(product: product),
      ),
    );
  }

  void _openEditProduct(ProductModel product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProductScreen(product: product),
      ),
    );
  }

  Future<void> _deleteProduct(ProductModel product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text(
          'Are you sure you want to remove "${product.name}" from your catalog?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _dbService.deleteProduct(product.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product removed successfully'),
              backgroundColor: AppColors.primary,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete product: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final farmer = authProvider.currentFarmer;

    if (farmer == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddProduct,
        backgroundColor: AppColors.primaryContainer,
        icon: const Icon(Icons.add, color: AppColors.onPrimary),
        label: const Text(
          'Add Product',
          style: TextStyle(
            color: AppColors.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopHeader(),
            _buildSearchAndFilters(),
            Expanded(
              child: StreamBuilder<List<ProductModel>>(
                stream: _dbService.streamProductsByFarmer(farmer.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                          const SizedBox(height: 12),
                          Text(
                            'Error loading products',
                            style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 16),
                          ),
                        ],
                      ),
                    );
                  }

                  final allProducts = snapshot.data ?? [];

                  if (allProducts.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 64,
                              color: AppColors.outline,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No products in your catalog',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Start listing fresh produce from your farm to receive orders.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: _openAddProduct,
                              icon: const Icon(Icons.add),
                              label: const Text('Add Your First Product'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final filtered = allProducts.where((p) {
                    
                    if (_searchQuery.isNotEmpty) {
                      final matchName =
                          p.name.toLowerCase().contains(_searchQuery);
                      final matchCat =
                          p.categoryName.toLowerCase().contains(_searchQuery);
                      final matchDesc =
                          p.description.toLowerCase().contains(_searchQuery);
                      if (!matchName && !matchCat && !matchDesc) return false;
                    }

                    if (_selectedCategory != 'All') {
                      if (p.categoryName.toLowerCase() !=
                              _selectedCategory.toLowerCase() &&
                          p.categoryId != _selectedCategory) {
                        return false;
                      }
                    }

                    final isAvail = p.isAvailable && p.quantity > 0;
                    if (_selectedStockStatus == 'In Stock' && !isAvail) {
                      return false;
                    }
                    if (_selectedStockStatus == 'Low Stock' &&
                        (!isAvail || p.quantity >= 5)) {
                      return false;
                    }
                    if (_selectedStockStatus == 'Out of Stock' && isAvail) {
                      return false;
                    }

                    return true;
                  }).toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 56,
                            color: AppColors.outline,
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'No matching products found',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Try clearing search or filters to see all products.',
                            style: TextStyle(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _searchCtrl.clear();
                                _searchQuery = '';
                                _selectedCategory = 'All';
                                _selectedStockStatus = 'All';
                              });
                            },
                            child: const Text('Reset Filters'),
                          ),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(16.0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.70,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final product = filtered[index];
                      return _buildProductCard(product);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.inventory_2,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'My Products',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                  Text(
                    'Manage your farm catalog',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          OutlinedButton.icon(
            onPressed: _openCategoriesScreen,
            icon: const Icon(Icons.category_outlined, size: 16),
            label: const Text('Categories'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 36),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Column(
      children: [
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Container(
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.surfaceVariant),
            ),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (val) {
                setState(() => _searchQuery = val.trim().toLowerCase());
              },
              decoration: InputDecoration(
                hintText: 'Search products...',
                hintStyle: TextStyle(fontSize: 13, color: AppColors.outline),
                prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.outline),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18, color: AppColors.outline),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
              ),
            ),
          ),
        ),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              _buildFilterChip('All', _selectedStockStatus == 'All', () {
                setState(() => _selectedStockStatus = 'All');
              }),
              const SizedBox(width: 6),
              _buildFilterChip('In Stock', _selectedStockStatus == 'In Stock', () {
                setState(() => _selectedStockStatus = 'In Stock');
              }),
              const SizedBox(width: 6),
              _buildFilterChip('Low Stock', _selectedStockStatus == 'Low Stock', () {
                setState(() => _selectedStockStatus = 'Low Stock');
              }),
              const SizedBox(width: 6),
              _buildFilterChip('Out of Stock', _selectedStockStatus == 'Out of Stock', () {
                setState(() => _selectedStockStatus = 'Out of Stock');
              }),
            ],
          ),
        ),
        const SizedBox(height: 6),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryContainer
              : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryContainer : AppColors.surfaceVariant,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : AppColors.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(ProductModel product) {
    final bool isAvailable = product.isAvailable && product.quantity > 0;
    final bool isLowStock = isAvailable && product.quantity < 5;

    final Color badgeColor = !isAvailable
        ? AppColors.error
        : (isLowStock ? AppColors.warning : AppColors.primary);
    final String badgeText = !isAvailable
        ? 'Out of Stock'
        : (isLowStock ? 'Low Stock' : 'In Stock');

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.surfaceVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openProductDetails(product),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            Expanded(
              flex: 4,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (product.imageUrl != null && product.imageUrl!.isNotEmpty)
                    Image.network(
                      product.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.surfaceContainerLow,
                        child: const Icon(
                          Icons.image_not_supported_outlined,
                          color: AppColors.outline,
                        ),
                      ),
                    )
                  else
                    Container(
                      color: AppColors.surfaceContainerLow,
                      child: const Icon(
                        Icons.image_outlined,
                        color: AppColors.outline,
                      ),
                    ),
                  
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        badgeText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  
                  if (product.isOrganic)
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'ORGANIC',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (product.categoryName.isNotEmpty)
                          Text(
                            product.categoryName.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: AppColors.outline,
                              letterSpacing: 0.5,
                            ),
                          ),
                        const SizedBox(height: 2),
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: AppColors.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${product.quantity.truncateToDouble() == product.quantity ? product.quantity.toInt() : product.quantity} ${product.unit} available',
                          style: TextStyle(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rs. ${product.price.toStringAsFixed(0)} / ${product.unit}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkWell(
                              onTap: () => _openEditProduct(product),
                              borderRadius: BorderRadius.circular(4),
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Icon(
                                  Icons.edit_outlined,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () => _deleteProduct(product),
                              borderRadius: BorderRadius.circular(4),
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: AppColors.errorContainer,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Icon(
                                  Icons.delete_outline,
                                  size: 16,
                                  color: AppColors.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
