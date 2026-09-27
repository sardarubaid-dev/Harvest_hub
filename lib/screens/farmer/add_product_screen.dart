import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/category_model.dart';
import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../theme/app_theme.dart';
import 'farmer_categories_screen.dart';

class AddProductScreen extends StatefulWidget {
  final String? initialCategoryId;

  const AddProductScreen({super.key, this.initialCategoryId});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseService _dbService = DatabaseService();

  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();
  final TextEditingController _priceCtrl = TextEditingController();
  final TextEditingController _quantityCtrl = TextEditingController();
  final TextEditingController _imageCtrl = TextEditingController();

  String _selectedUnit = 'kg';
  String? _selectedCategoryId;
  String? _selectedCategoryName;
  bool _isOrganic = false;
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

  // Curated agricultural produce presets for quick preview & image selection
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
    // Default image to first preset
    _imageCtrl.text = _sampleImages[0]['url']!;
    _imageCtrl.addListener(() {
      setState(() {});
    });

    if (widget.initialCategoryId != null) {
      _selectedCategoryId = widget.initialCategoryId;
    }
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

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategoryId == null || _selectedCategoryId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a product category'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final farmer = authProvider.currentFarmer;
    if (farmer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Farmer account not found'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final double price = double.parse(_priceCtrl.text.trim());
      final double quantity = double.parse(_quantityCtrl.text.trim());
      final String imageUrl = _imageCtrl.text.trim().isNotEmpty
          ? _imageCtrl.text.trim()
          : _sampleImages[0]['url']!;

      final newProduct = ProductModel(
        id: '',
        farmerId: farmer.id,
        farmerName: farmer.farmName.isNotEmpty ? farmer.farmName : 'Local Farm',
        categoryId: _selectedCategoryId!,
        categoryName: _selectedCategoryName ?? '',
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        price: price,
        unit: _selectedUnit,
        quantity: quantity,
        imageUrl: imageUrl,
        isAvailable: quantity > 0,
        isOrganic: _isOrganic,
        createdAt: DateTime.now(),
      );

      await _dbService.addProduct(newProduct);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product added successfully'),
            backgroundColor: AppColors.primary,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add product: $e'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          'Add New Product',
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
                              Icons.image_outlined,
                              size: 48,
                              color: AppColors.outline,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Image preview will appear here',
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
                          'Preview',
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

              // Quick Image Presets selector
              const Text(
                'Or choose a produce photo:',
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
                  hintText: 'e.g., Fresh Organic Tomatoes',
                  prefixIcon: Icon(Icons.shopping_bag_outlined, color: AppColors.outline),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Please enter product name';
                  }
                  if (v.trim().length < 2) {
                    return 'Product name is too short';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Category Selector
              StreamBuilder<List<CategoryModel>>(
                stream: _dbService.streamCategories(),
                builder: (context, snapshot) {
                  final categories = snapshot.data ?? [];
                  if (categories.isNotEmpty && _selectedCategoryId == null) {
                    _selectedCategoryId = categories.first.id;
                    _selectedCategoryName = categories.first.name;
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                              const Icon(
                                Icons.category_outlined,
                                color: AppColors.outline,
                              ),
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
                                      _selectedCategoryName ?? 'Tap to select category',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: _selectedCategoryName != null
                                            ? AppColors.primary
                                            : AppColors.onSurfaceVariant,
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
                                      'Browse',
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
                    ],
                  );
                },
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
                        hintText: '280',
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
                  hintText: 'e.g. 50',
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
                  hintText: 'Describe freshness, harvest details, quality...',
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

              // Organic Checkbox
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

              // Save Button
              ElevatedButton(
                onPressed: _isLoading ? null : _saveProduct,
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
                        'Save & Add Product',
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
