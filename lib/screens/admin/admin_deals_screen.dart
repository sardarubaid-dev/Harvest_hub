import 'package:flutter/material.dart';
import 'package:harvest_hub/models/product_model.dart';
import 'package:harvest_hub/services/database_service.dart';
import 'package:harvest_hub/theme/app_theme.dart';

class AdminDealsScreen extends StatefulWidget {
  const AdminDealsScreen({Key? key}) : super(key: key);

  @override
  State<AdminDealsScreen> createState() => _AdminDealsScreenState();
}

class _AdminDealsScreenState extends State<AdminDealsScreen> {
  final DatabaseService _dbService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: AppBar(
        title: const Text('Manage Deals of the Day'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.onSurface,
        elevation: 1,
      ),
      body: StreamBuilder<List<ProductModel>>(
        stream: _dbService.streamAllProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final products = snapshot.data ?? [];
          if (products.isEmpty) {
            return const Center(child: Text('No products available to make deals.'));
          }

          // Sort so deals show up first
          products.sort((a, b) {
            if (a.isDealOfTheDay && !b.isDealOfTheDay) return -1;
            if (!a.isDealOfTheDay && b.isDealOfTheDay) return 1;
            return a.name.compareTo(b.name);
          });

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                elevation: product.isDealOfTheDay ? 3 : 1,
                color: product.isDealOfTheDay ? const Color(0xFFE8F5E9) : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: product.isDealOfTheDay ? AppColors.primary : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                        ? Image.network(
                            product.imageUrl!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => const Icon(Icons.image, color: Colors.grey),
                          )
                        : const Icon(Icons.image, color: Colors.grey, size: 50),
                  ),
                  title: Text(
                    product.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: product.isDealOfTheDay ? AppColors.primary : AppColors.onSurface,
                    ),
                  ),
                  subtitle: Text('Price: Rs. ${product.price} | Stock: ${product.quantity} ${product.unit}'),
                  trailing: Switch(
                    value: product.isDealOfTheDay,
                    activeColor: AppColors.primary,
                    onChanged: (val) {
                      _toggleDealStatus(product, val);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _toggleDealStatus(ProductModel product, bool isDeal) async {
    if (isDeal) {
      final originalPriceController = TextEditingController(text: product.price.toString());
      final discountPriceController = TextEditingController();

      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Make Deal of the Day'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: originalPriceController,
                  decoration: const InputDecoration(labelText: 'Original Price (Rs)'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: discountPriceController,
                  decoration: const InputDecoration(labelText: 'New Deal Price (Rs)'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final orig = double.tryParse(originalPriceController.text) ?? product.price;
                  final newPrice = double.tryParse(discountPriceController.text) ?? product.price;
                  
                  final updatedProduct = product.copyWith(
                    isDealOfTheDay: true,
                    originalPrice: orig,
                    price: newPrice,
                  );
                  await _dbService.updateProduct(updatedProduct);
                  if (mounted) Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      );
    } else {
      final updatedProduct = product.copyWith(
        isDealOfTheDay: false,
        originalPrice: product.originalPrice ?? product.price,
      );
      await _dbService.updateProduct(updatedProduct);
    }
  }
}
