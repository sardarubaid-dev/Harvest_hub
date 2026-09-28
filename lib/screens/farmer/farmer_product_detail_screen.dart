import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../services/database_service.dart';
import '../../theme/app_theme.dart';
import 'edit_product_screen.dart';

class FarmerProductDetailScreen extends StatefulWidget {
  final ProductModel product;

  const FarmerProductDetailScreen({super.key, required this.product});

  @override
  State<FarmerProductDetailScreen> createState() =>
      _FarmerProductDetailScreenState();
}

class _FarmerProductDetailScreenState extends State<FarmerProductDetailScreen> {
  final DatabaseService _dbService = DatabaseService();
  late ProductModel _product;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
  }

  Future<void> _openEditScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProductScreen(product: _product),
      ),
    );

    if (result == 'deleted') {
      if (mounted) Navigator.pop(context);
    } else if (result is ProductModel) {
      setState(() {
        _product = result;
      });
    }
  }

  Future<void> _quickStockAdjust() async {
    final qtyCtrl = TextEditingController(
      text: _product.quantity.truncateToDouble() == _product.quantity
          ? _product.quantity.toInt().toString()
          : _product.quantity.toString(),
    );

    final updatedQty = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Inventory'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Update current stock quantity for ${_product.name}:',
              style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: qtyCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Stock Quantity',
                suffixText: _product.unit,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(qtyCtrl.text.trim());
              if (val != null && val >= 0) {
                Navigator.pop(context, val);
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );

    if (updatedQty != null) {
      try {
        await _dbService.updateProductStock(_product.id, updatedQty);
        setState(() {
          _product = _product.copyWith(
            quantity: updatedQty,
            isAvailable: updatedQty > 0,
          );
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Stock quantity updated'),
              backgroundColor: AppColors.primary,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update stock: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text(
          'Are you sure you want to remove "${_product.name}"? This action cannot be undone.',
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
        await _dbService.deleteProduct(_product.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product removed'),
              backgroundColor: AppColors.primary,
            ),
          );
          Navigator.pop(context, 'deleted');
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
    final bool isAvailable = _product.isAvailable && _product.quantity > 0;
    final bool isLowStock = isAvailable && _product.quantity < 5;

    final Color statusColor = !isAvailable
        ? AppColors.error
        : (isLowStock ? AppColors.warning : AppColors.primary);
    final String statusText = !isAvailable
        ? 'Out of Stock'
        : (isLowStock ? 'Low Stock' : 'In Stock');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          'Product Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
            tooltip: 'Edit Product',
            onPressed: _openEditScreen,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            tooltip: 'Delete Product',
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: ListView(
        children: [
          
          Container(
            height: 260,
            width: double.infinity,
            color: AppColors.surfaceContainerLow,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (_product.imageUrl != null && _product.imageUrl!.isNotEmpty)
                  Image.network(
                    _product.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        size: 64,
                        color: AppColors.outline,
                      ),
                    ),
                  )
                else
                  const Center(
                    child: Icon(
                      Icons.image_outlined,
                      size: 64,
                      color: AppColors.outline,
                    ),
                  ),
                
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.surfaceVariant),
                      ),
                      child: Text(
                        _product.categoryName.isNotEmpty
                            ? _product.categoryName.toUpperCase()
                            : 'PRODUCE',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    if (_product.isOrganic) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.onTertiaryContainer,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.primaryContainer),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.spa,
                              size: 13,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'ORGANIC',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),

                Text(
                  _product.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.surfaceVariant),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Price',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Rs. ${_product.price.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              'per ${_product.unit}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.surfaceVariant),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'In Stock',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                                InkWell(
                                  onTap: _quickStockAdjust,
                                  child: const Text(
                                    'Adjust',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_product.quantity.truncateToDouble() == _product.quantity ? _product.quantity.toInt() : _product.quantity}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                            Text(
                              _product.unit,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                const Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.surfaceVariant),
                  ),
                  child: Text(
                    _product.description.isNotEmpty
                        ? _product.description
                        : 'No description provided.',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  'Product Specifications',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.surfaceVariant),
                  ),
                  child: Column(
                    children: [
                      _buildSpecRow('Category', _product.categoryName),
                      const Divider(height: 1, color: AppColors.surfaceVariant),
                      _buildSpecRow('Measuring Unit', _product.unit),
                      const Divider(height: 1, color: AppColors.surfaceVariant),
                      _buildSpecRow('Organic Produce', _product.isOrganic ? 'Yes' : 'No'),
                      const Divider(height: 1, color: AppColors.surfaceVariant),
                      _buildSpecRow('Market Availability', isAvailable ? 'Available' : 'Unavailable'),
                      const Divider(height: 1, color: AppColors.surfaceVariant),
                      _buildSpecRow('Farm Origin', _product.farmerName ?? 'Local Farm'),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                ElevatedButton.icon(
                  onPressed: _openEditScreen,
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Edit Product Details'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
