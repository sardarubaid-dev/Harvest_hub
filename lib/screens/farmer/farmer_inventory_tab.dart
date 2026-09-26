import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:harvest_hub/theme/app_theme.dart';
import 'package:harvest_hub/providers/auth_provider.dart';
import 'package:harvest_hub/services/database_service.dart';
import 'package:harvest_hub/models/product_model.dart';
import 'package:harvest_hub/models/category_model.dart';

class FarmerInventoryTab extends StatefulWidget {
  const FarmerInventoryTab({super.key});

  @override
  State<FarmerInventoryTab> createState() => _FarmerInventoryTabState();
}

class _FarmerInventoryTabState extends State<FarmerInventoryTab> {
  final DatabaseService _dbService = DatabaseService();

  void _showAddProductModal(BuildContext context, String farmerId, String farmerName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _AddProductModal(farmerId: farmerId, farmerName: farmerName),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final farmer = authProvider.currentFarmer;

    if (farmer == null) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddProductModal(context, farmer.id, farmer.farmName),
        backgroundColor: AppColors.primaryContainer,
        icon: const Icon(Icons.add, color: AppColors.onPrimary),
        label: const Text(
          'Add Product',
          style: TextStyle(color: AppColors.onPrimary, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: StreamBuilder<List<ProductModel>>(
                stream: _dbService.streamProductsByFarmer(farmer.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                  }
                  
                  final products = snapshot.data ?? [];
                  
                  if (products.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.outline),
                          const SizedBox(height: 16),
                          Text('No products in inventory', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 16)),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(16.0),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return _buildProductCard(context, product, farmer.id, farmer.farmName ?? '');
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.inventory_2, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Inventory',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
                Text(
                  'Manage your farm products',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, ProductModel product, String farmerId, String farmerName) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  product.imageUrl ?? '',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade300, child: const Icon(Icons.image_not_supported)),
                ),
                if (!product.isAvailable || product.quantity == 0)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(8)),
                      child: const Text('Out of Stock', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text('${product.quantity} ${product.unit} available', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('\$${product.price.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.edit, size: 18, color: AppColors.primary),
                          onPressed: () => _showAddProductModal(context, farmerId, farmerName), // Ideally pass product for editing
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.delete, size: 18, color: AppColors.error),
                          onPressed: () => _dbService.deleteProduct(product.id),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Reuse the modal from the old code, simplified
class _AddProductModal extends StatefulWidget {
  final String farmerId;
  final String farmerName;

  const _AddProductModal({required this.farmerId, required this.farmerName});

  @override
  State<_AddProductModal> createState() => _AddProductModalState();
}

class _AddProductModalState extends State<_AddProductModal> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseService _dbService = DatabaseService();
  
  String name = '';
  String description = '';
  double price = 0.0;
  double quantity = 0.0;
  String unit = 'kg';
  String categoryId = '';
  String categoryName = '';
  String imageUrl = ''; 
  bool isOrganic = false;

  final List<String> _units = ['kg', 'g', 'bunch', 'dozen', 'piece', 'L', 'jar'];

  List<CategoryModel> categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  void _loadCategories() {
    _dbService.streamCategories().listen((cats) {
      if (mounted) {
        setState(() {
          categories = cats;
          if (categories.isNotEmpty && categoryId.isEmpty) {
            categoryId = categories.first.id;
            categoryName = categories.first.name;
          }
        });
      }
    });
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      final product = ProductModel(
        id: '',
        farmerId: widget.farmerId,
        farmerName: widget.farmerName,
        categoryId: categoryId,
        categoryName: categoryName,
        name: name,
        description: description,
        price: price,
        quantity: quantity,
        unit: unit,
        imageUrl: imageUrl.isNotEmpty ? imageUrl : 'https://images.unsplash.com/photo-1518843875459-f738682238a6?w=500',
        isAvailable: quantity > 0,
        isOrganic: isOrganic,
      );

      await _dbService.addProduct(product);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Add New Product', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Product Name', border: OutlineInputBorder()),
              validator: (v) => v!.isEmpty ? 'Required' : null,
              onSaved: (v) => name = v!,
            ),
            const SizedBox(height: 12),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
              maxLines: 2,
              onSaved: (v) => description = v ?? '',
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(labelText: 'Price (\$)', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                    onSaved: (v) => price = double.parse(v!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Unit', border: OutlineInputBorder()),
                    value: unit,
                    items: _units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                    onChanged: (val) => setState(() => unit = val!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Quantity Available', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              validator: (v) => v!.isEmpty ? 'Required' : null,
              onSaved: (v) => quantity = double.parse(v!),
            ),
            const SizedBox(height: 12),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Image URL (optional)', 
                border: OutlineInputBorder(),
                hintText: 'https://...',
              ),
              onSaved: (v) => imageUrl = v ?? '',
            ),
            const SizedBox(height: 12),
            if (categories.isNotEmpty)
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                value: categoryId,
                items: categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                onChanged: (val) {
                  setState(() {
                    categoryId = val!;
                    categoryName = categories.firstWhere((c) => c.id == val).name;
                  });
                },
              ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Organic Product'),
              subtitle: const Text('Is this product verified organic and pesticide-free?'),
              value: isOrganic,
              activeColor: AppColors.primary,
              onChanged: (val) => setState(() => isOrganic = val),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _submit,
              child: const Text('Save Product'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
