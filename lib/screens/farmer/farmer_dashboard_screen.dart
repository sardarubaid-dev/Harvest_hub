import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:harvest_hub/theme/app_theme.dart';
import 'package:harvest_hub/providers/auth_provider.dart';
import 'package:harvest_hub/services/database_service.dart';
import 'package:harvest_hub/models/farmer_model.dart';
import 'package:harvest_hub/models/product_model.dart';
import 'package:harvest_hub/models/order_model.dart';

class FarmerDashboardScreen extends StatefulWidget {
  const FarmerDashboardScreen({super.key});

  @override
  State<FarmerDashboardScreen> createState() => _FarmerDashboardScreenState();
}

class _FarmerDashboardScreenState extends State<FarmerDashboardScreen> {
  final DatabaseService _dbService = DatabaseService();
  int _currentTabIndex = 0;

  void _showAddProductModal(
    BuildContext context,
    String farmerId,
    String farmerName,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) =>
          _AddProductModal(farmerId: farmerId, farmerName: farmerName),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final farmer = authProvider.currentFarmer;

    if (farmer == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Farmer Dashboard'),
          backgroundColor: Colors.amber.shade800,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.amber),
              const SizedBox(height: 16),
              const Text('Setting up your Farmer Profile...'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => authProvider.logout(),
                child: const Text('Sign Out'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.amber.shade800,
        foregroundColor: Colors.white,
        title: Row(
          children: [
            const Icon(Icons.agriculture, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              farmer.farmName.isNotEmpty ? farmer.farmName : 'Farmer Dashboard',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () => authProvider.logout(),
          ),
        ],
      ),
      body: _currentTabIndex == 0
          ? _buildInventoryTab(context, farmer)
          : _buildOrdersTab(context, farmer),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTabIndex,
        onTap: (index) => setState(() => _currentTabIndex = index),
        selectedItemColor: Colors.amber.shade800,
        unselectedItemColor: AppColors.outline,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            label: 'My Inventory',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            label: 'Customer Orders',
          ),
        ],
      ),
      floatingActionButton: _currentTabIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () =>
                  _showAddProductModal(context, farmer.id, farmer.farmName),
              backgroundColor: Colors.amber.shade800,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Add Product',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildInventoryTab(BuildContext context, FarmerModel farmer) {
    return StreamBuilder<List<ProductModel>>(
      stream: _dbService.streamProductsByFarmer(farmer.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.amber),
          );
        }

        List<ProductModel> products = snapshot.data ?? [];

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Card(
                      color: Colors.amber.shade50,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.amber.shade800,
                              child: const Icon(
                                Icons.store,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    farmer.farmName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    '${farmer.location} • ${farmer.contactNumber}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: farmer.isApproved
                                    ? Colors.green
                                    : Colors.orange,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                farmer.isApproved ? 'Approved' : 'Pending',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Active Listings',
                            '${products.length}',
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStatCard(
                            'Low Stock Items',
                            '${products.where((p) => p.quantity <= 5).length}',
                            Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            if (products.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.eco_outlined,
                        size: 64,
                        color: AppColors.outline,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No products added yet. Click Add Product below!',
                        style: TextStyle(color: AppColors.outline),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    ProductModel product = products[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: ListTile(
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child:
                                product.imageUrl != null &&
                                    product.imageUrl!.isNotEmpty
                                ? Image.network(
                                    product.imageUrl!,
                                    fit: BoxFit.cover,
                                  )
                                : const Icon(Icons.eco, color: Colors.green),
                          ),
                          title: Text(
                            product.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '\$${product.price.toStringAsFixed(2)} / ${product.unit} • Stock: ${product.quantity.toInt()}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed: () =>
                                    _showEditStockModal(context, product),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () async {
                                  await _dbService.deleteProduct(product.id);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }, childCount: products.length),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppColors.outline),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersTab(BuildContext context, FarmerModel farmer) {
    return StreamBuilder<List<OrderModel>>(
      stream: _dbService.streamFarmerOrders(farmer.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.amber),
          );
        }

        List<OrderModel> orders = snapshot.data ?? [];

        if (orders.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox, size: 64, color: AppColors.outline),
                SizedBox(height: 16),
                Text(
                  'No customer orders yet.',
                  style: TextStyle(color: AppColors.outline, fontSize: 16),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            OrderModel order = orders[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Order #${order.id.substring(0, 6)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        DropdownButton<String>(
                          value: order.status,
                          underline: const SizedBox(),
                          items:
                              [
                                    'Pending',
                                    'Confirmed',
                                    'Ready for Pickup',
                                    'Completed',
                                    'Cancelled',
                                  ]
                                  .map(
                                    (status) => DropdownMenuItem(
                                      value: status,
                                      child: Text(
                                        status,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (newStatus) {
                            if (newStatus != null) {
                              _dbService.updateOrderStatus(order.id, newStatus);
                            }
                          },
                        ),
                      ],
                    ),
                    const Divider(),
                    Text(
                      'Customer: ${order.customerName ?? 'Customer'} (${order.customerPhone ?? ''})',
                    ),
                    const SizedBox(height: 6),
                    ...order.items.map(
                      (item) => Text(
                        '• ${item.quantity} ${item.unit} x ${item.productName} (\$${(item.price * item.quantity).toStringAsFixed(2)})',
                      ),
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Revenue:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '\$${order.totalAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade800,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showEditStockModal(BuildContext context, ProductModel product) {
    final qtyController = TextEditingController(
      text: product.quantity.toString(),
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Stock: ${product.name}'),
        content: TextField(
          controller: qtyController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Stock Quantity'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              double newQty =
                  double.tryParse(qtyController.text) ?? product.quantity;
              await _dbService.updateProductStock(product.id, newQty);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _AddProductModal extends StatefulWidget {
  final String farmerId;
  final String farmerName;

  const _AddProductModal({required this.farmerId, required this.farmerName});

  @override
  State<_AddProductModal> createState() => _AddProductModalState();
}

class _AddProductModalState extends State<_AddProductModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _qtyController = TextEditingController();
  final _unitController = TextEditingController(text: 'kg');
  final _imageController = TextEditingController();

  String _selectedCategory = 'Vegetables';

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _qtyController.dispose();
    _unitController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  void _submitProduct() async {
    if (!_formKey.currentState!.validate()) return;

    double price = double.parse(_priceController.text);
    double qty = double.parse(_qtyController.text);

    ProductModel newProduct = ProductModel(
      id: '',
      farmerId: widget.farmerId,
      categoryId: _selectedCategory,
      categoryName: _selectedCategory,
      name: _nameController.text.trim(),
      description: _descController.text.trim(),
      price: price,
      unit: _unitController.text.trim(),
      quantity: qty,
      imageUrl: _imageController.text.trim().isNotEmpty
          ? _imageController.text.trim()
          : null,
      isAvailable: qty > 0,
      farmerName: widget.farmerName,
    );

    await DatabaseService().addProduct(newProduct);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add New Farm Harvest Item',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Item Name (e.g. Organic Tomatoes)',
                  ),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items:
                      [
                            'Fruits',
                            'Vegetables',
                            'Organic Products',
                            'Dairy',
                            'Pulses & Grains',
                            'Herbs & Spices',
                          ]
                          .map(
                            (cat) =>
                                DropdownMenuItem(value: cat, child: Text(cat)),
                          )
                          .toList(),
                  onChanged: (val) => setState(
                    () => _selectedCategory = val ?? _selectedCategory,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Price (\$)',
                        ),
                        validator: (val) =>
                            val == null || val.isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _unitController,
                        decoration: const InputDecoration(
                          labelText: 'Unit (kg, lb, dozen)',
                        ),
                        validator: (val) =>
                            val == null || val.isEmpty ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _qtyController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Initial Stock Quantity',
                  ),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _imageController,
                  decoration: const InputDecoration(
                    labelText: 'Image URL (Optional)',
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _submitProduct,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber.shade800,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text(
                      'Add Product to Marketplace',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
