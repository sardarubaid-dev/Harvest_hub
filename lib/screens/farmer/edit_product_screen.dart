import 'package:flutter/material.dart';
import '../../models/category_model.dart';
import '../../models/product_model.dart';
import '../../services/database_service.dart';
import '../../theme/app_theme.dart';
import 'farmer_categories_screen.dart';

class EditProductScreen extends StatefulWidget {
  final ProductModel product;

  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseService _dbService = DatabaseService();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _quantityCtrl;
  late final TextEditingController _imageCtrl;

  late String _selectedUnit;
  late String _selectedCategoryId;
  late String _selectedCategoryName;
  late bool _isAvailable;
  late bool _isOrganic;
  bool _isLoading = false;

  final List<String> _units = [
    'kg',
    'g',
    'bunch',
    'dozen',
    'piece',
    'L',
    'jar',
    'box',
  ];

  final List<Map<String, String>> _sampleImages = [
    {
      'title': 'Tomatoes',
      'url':
          'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?q=80&w=600&auto=format&fit=crop',
    },
    {
      'title': 'Spinach',
      'url':
          'https://images.unsplash.com/photo-1576045057995-568f588f82fb?q=80&w=600&auto=format&fit=crop',
    },
    {
      'title': 'Apples',
      'url':
          'https://images.unsplash.com/photo-1568702846914-96b305d2aaeb?q=80&w=600&auto=format&fit=crop',
    },
    {
      'title': 'Carrots',
      'url':
          'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?q=80&w=600&auto=format&fit=crop',
    },
    {
      'title': 'Milk',
      'url':
          'https://images.unsplash.com/photo-1563636619-e9143da7973b?q=80&w=600&auto=format&fit=crop',
    },
    {
      'title': 'Honey',
      'url':
          'https://images.unsplash.com/photo-1628151015968-3a4429e9ef04?q=80&w=600&auto=format&fit=crop',
    },
    {
      'title': 'Grains',
      'url':
          'https://images.unsplash.com/photo-1586201375761-83865001e31c?q=80&w=600&auto=format&fit=crop',
    },
    {
      'title': 'Herbs',
      'url':
          'https://images.unsplash.com/photo-1596040033229-a9821ebd058d?q=80&w=600&auto=format&fit=crop',
    },
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameCtrl = TextEditingController(text: p.name);
    _descCtrl = TextEditingController(text: p.description);
    _priceCtrl = TextEditingController(
      text: p.price.truncateToDouble() == p.price
          ? p.price.toInt().toString()
          : p.price.toString(),
    );
    _quantityCtrl = TextEditingController(
      text: p.quantity.truncateToDouble() == p.quantity
          ? p.quantity.toInt().toString()
          : p.quantity.toString(),
    );
    _imageCtrl = TextEditingController(text: p.imageUrl ?? '');
    _imageCtrl.addListener(() {
      setState(() {});
    });

    _selectedUnit = _units.contains(p.unit) ? p.unit : 'kg';
    _selectedCategoryId = p.categoryId;
    _selectedCategoryName = p.categoryName.isNotEmpty ? p.categoryName : 'Selected';
    _isAvailable = p.isAvailable && p.quantity > 0;
    _isOrganic = p.isOrganic;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _quantityCtrl.dispose();
    _imageCtrl.dispose();
    super.dispose();
  }

  Future<void> _openCategoryPicker() async {
    final selected = await Navigator.push<CategoryModel>(
      context,
      MaterialPageRoute(
        builder: (context) => FarmerCategoriesScreen(
          isSelectionMode: true,
          selectedCategoryId: _selectedCategoryId,
        ),
      ),
    );

    if (selected != null) {
      setState(() {
        _selectedCategoryId = selected.id;
        _selectedCategoryName = selected.name;
      });
    }
  }

  Future<void> _updateProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final double price = double.parse(_priceCtrl.text.trim());
      final double quantity = double.parse(_quantityCtrl.text.trim());
      final String imageUrl = _imageCtrl.text.trim();

      final updatedProduct = widget.product.copyWith(
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        price: price,
        unit: _selectedUnit,
        quantity: quantity,
        imageUrl: imageUrl,
        categoryId: _selectedCategoryId,
        categoryName: _selectedCategoryName,
        isAvailable: _isAvailable && quantity > 0,
        isOrganic: _isOrganic,
      );

      await _dbService.updateProduct(updatedProduct);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product updated successfully'),
            backgroundColor: AppColors.primary,
          ),
        );
        Navigator.pop(context, updatedProduct);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update product: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to remove "${widget.product.name}"? This action cannot be undone.'),
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
        await _dbService.deleteProduct(widget.product.id);
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          'Edit Product',
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
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            tooltip: 'Delete Product',
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Image Preview Card
              Container(
                height: 180,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.surfaceVariant),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      _imageCtrl.text.trim(),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_not_supported_outlined,
                              size: 48,
                              color: AppColors.outline,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Image preview unavailable',
                              style: TextStyle(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Current Image',
                          style: TextStyle(color: Colors.white, fontSize: 11),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Image URL input
              TextFormField(
                controller: _imageCtrl,
                decoration: const InputDecoration(
                  labelText: 'Product Image URL *',
                  hintText: 'https://...',
                  prefixIcon: Icon(Icons.link, color: AppColors.outline),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Product image URL is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),

              // Quick Image Presets
              const Text(
                'Replace with produce photo:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _sampleImages.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final item = _sampleImages[index];
                    final isSelected = _imageCtrl.text == item['url'];
                    return ChoiceChip(
                      label: Text(item['title']!),
                      selected: isSelected,
                      selectedColor: AppColors.primaryContainer,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        color: isSelected ? Colors.white : AppColors.onSurface,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (_) {
                        setState(() {
                          _imageCtrl.text = item['url']!;
                        });
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Product Name
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Product Name *',
                  prefixIcon: Icon(Icons.shopping_bag_outlined, color: AppColors.outline),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Please enter product name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Category Selector
              InkWell(
                onTap: _openCategoryPicker,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFD6DDD6)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.category_outlined, color: AppColors.outline),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Category *',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              _selectedCategoryName,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          children: [
                            Text(
                              'Change',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              size: 16,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Price and Unit
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _priceCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Price (Rs.) *',
                        prefixIcon: Icon(Icons.attach_money, color: AppColors.outline),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Enter price';
                        }
                        final parsed = double.tryParse(v.trim());
                        if (parsed == null || parsed <= 0) {
                          return 'Invalid price';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: _selectedUnit,
                      decoration: const InputDecoration(
                        labelText: 'Unit *',
                        prefixIcon: Icon(Icons.scale_outlined, color: AppColors.outline),
                      ),
                      items: _units.map((u) {
                        return DropdownMenuItem(value: u, child: Text(u));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedUnit = val);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Quantity / Inventory
              TextFormField(
                controller: _quantityCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Stock Quantity *',
                  suffixText: _selectedUnit,
                  prefixIcon: const Icon(Icons.inventory_2_outlined, color: AppColors.outline),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Enter quantity';
                  }
                  final parsed = double.tryParse(v.trim());
                  if (parsed == null || parsed < 0) {
                    return 'Invalid quantity';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  alignLabelWithHint: true,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Please enter product description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Availability Switch
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFD6DDD6)),
                ),
                child: SwitchListTile(
                  title: const Text(
                    'Available in Market',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    _isAvailable ? 'Customers can view and order this item' : 'Marked out-of-stock / hidden from orders',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  value: _isAvailable,
                  activeColor: AppColors.primary,
                  onChanged: (val) => setState(() => _isAvailable = val),
                ),
              ),
              const SizedBox(height: 12),

              // Organic Switch
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFD6DDD6)),
                ),
                child: SwitchListTile(
                  title: const Text(
                    'Organic Certified Produce',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                  subtitle: const Text(
                    'Pesticide-free, grown using organic farm practices',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  value: _isOrganic,
                  activeColor: AppColors.primary,
                  onChanged: (val) => setState(() => _isOrganic = val),
                ),
              ),
              const SizedBox(height: 28),

              // Update Button
              ElevatedButton(
                onPressed: _isLoading ? null : _updateProduct,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
