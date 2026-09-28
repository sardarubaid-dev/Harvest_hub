import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../models/product_model.dart';
import '../../models/category_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../services/image_service.dart';
import '../../theme/app_theme.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseService _dbService = DatabaseService();

  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();
  final TextEditingController _priceCtrl = TextEditingController();
  final TextEditingController _originalPriceCtrl = TextEditingController();
  final TextEditingController _quantityCtrl = TextEditingController();
  
  List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  String _selectedUnit = 'kg';
  String? _selectedCategoryId;
  String? _selectedCategoryName;
  bool _isOrganic = false;
  bool _isDealOfTheDay = false;
  bool _isLoading = false;

  final List<String> _units = [
    'kg',
    'g',
    'bunch',
    'dozen',
    'piece',
    'L',
    'jar',
    'bottle'
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _originalPriceCtrl.dispose();
    _quantityCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    if (_selectedImages.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 5 images allowed')),
      );
      return;
    }

    try {
      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: 70,
        maxWidth: 1024,
      );
      
      if (images.isNotEmpty) {
        setState(() {
          final spaceLeft = 5 - _selectedImages.length;
          final imagesToAdd = images.take(spaceLeft).map((x) => File(x.path));
          _selectedImages.addAll(imagesToAdd);
        });
      }
    } catch (e) {
      debugPrint('Error picking images: $e');
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one image')),
      );
      return;
    }
    
    if (_isDealOfTheDay && _originalPriceCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter original price for Deal of the Day')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProv = Provider.of<AuthProvider>(context, listen: false);
      final farmerId = authProv.currentFarmer?.id;
      final farmerName = authProv.currentFarmer?.farmName;
      final marketName = authProv.currentFarmer?.location;

      if (farmerId == null) throw Exception('Farmer ID not found');

      // Upload images
      List<String> uploadedUrls = [];
      for (int i = 0; i < _selectedImages.length; i++) {
        final url = await ImageService.uploadImage(
          _selectedImages[i], 
          'temp_${DateTime.now().millisecondsSinceEpoch}_$i'
        );
        if (url != null) uploadedUrls.add(url);
      }

      if (uploadedUrls.isEmpty) throw Exception('Failed to upload images');

      final price = double.tryParse(_priceCtrl.text) ?? 0;
      final quantity = double.tryParse(_quantityCtrl.text) ?? 0;
      final originalPrice = _isDealOfTheDay ? double.tryParse(_originalPriceCtrl.text) : null;

      final newProduct = ProductModel(
        id: '',
        farmerId: farmerId,
        farmerName: farmerName,
        marketName: marketName,
        categoryId: _selectedCategoryId!,
        categoryName: _selectedCategoryName ?? '',
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        price: price,
        originalPrice: originalPrice,
        isDealOfTheDay: _isDealOfTheDay,
        unit: _selectedUnit,
        quantity: quantity,
        imageUrl: uploadedUrls.first,
        imageUrls: uploadedUrls,
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
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Add Product'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Images Section
                    const Text(
                      'Product Images (Up to 5)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _selectedImages.length + 1,
                        itemBuilder: (context, index) {
                          if (index == _selectedImages.length) {
                            return _selectedImages.length < 5
                                ? GestureDetector(
                                    onTap: _pickImages,
                                    child: Container(
                                      width: 100,
                                      margin: const EdgeInsets.only(right: 12),
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceContainerLow,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: AppColors.outline,
                                          style: BorderStyle.solid,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.add_a_photo,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  )
                                : const SizedBox();
                          }
                          return Stack(
                            children: [
                              Container(
                                width: 100,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  image: DecorationImage(
                                    image: FileImage(_selectedImages[index]),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 16,
                                child: GestureDetector(
                                  onTap: () => _removeImage(index),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Basic Info
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Product Name',
                        hintText: 'e.g., Fresh Tomatoes',
                      ),
                      validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Describe your product...',
                      ),
                      validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 24),

                    // Category
                    StreamBuilder<List<CategoryModel>>(
                      stream: _dbService.streamCategories(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const CircularProgressIndicator();
                        }
                        final categories = snapshot.data!;
                        return DropdownButtonFormField<String>(
                          value: _selectedCategoryId,
                          decoration: const InputDecoration(
                            labelText: 'Category',
                          ),
                          items: categories.map((cat) {
                            return DropdownMenuItem(
                              value: cat.id,
                              child: Text(cat.name),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedCategoryId = val;
                              _selectedCategoryName = categories
                                  .firstWhere((c) => c.id == val)
                                  .name;
                            });
                          },
                          validator: (v) => v == null ? 'Required' : null,
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Pricing & Inventory
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _priceCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Price (Rs)',
                              prefixText: 'Rs. ',
                            ),
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedUnit,
                            decoration: const InputDecoration(
                              labelText: 'Unit',
                            ),
                            items: _units.map((u) {
                              return DropdownMenuItem(
                                value: u,
                                child: Text(u),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedUnit = val);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _quantityCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Available Quantity ($_selectedUnit)',
                      ),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 24),

                    // Deal of the Day
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.outline),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          SwitchListTile(
                            title: const Text(
                              'Deal of the Day',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSurface,
                              ),
                            ),
                            subtitle: const Text(
                              'Promote this product as a special deal',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            value: _isDealOfTheDay,
                            activeColor: AppColors.primary,
                            onChanged: (val) => setState(() => _isDealOfTheDay = val),
                          ),
                          if (_isDealOfTheDay)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: TextFormField(
                                controller: _originalPriceCtrl,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Original Price (Rs)',
                                  prefixText: 'Rs. ',
                                  hintText: 'Enter price before discount',
                                ),
                                validator: (v) => _isDealOfTheDay && v!.isEmpty 
                                  ? 'Original price is required for deals' 
                                  : null,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Organic Switch
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.outline),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SwitchListTile(
                        title: const Text(
                          'Organic Product',
                          style: TextStyle(
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

                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveProduct,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Add Product'),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }
}
