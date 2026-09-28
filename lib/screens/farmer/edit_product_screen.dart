import 'package:flutter/material.dart';
import '../../models/category_model.dart';
import '../../models/product_model.dart';
import '../../services/database_service.dart';
import '../../services/image_service.dart';
import '../../theme/app_theme.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

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
  late final TextEditingController _originalPriceCtrl;
  late final TextEditingController _quantityCtrl;

  List<String> _existingImages = [];
  List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  late String _selectedUnit;
  late String _selectedCategoryId;
  late String _selectedCategoryName;
  late bool _isAvailable;
  late bool _isOrganic;
  late bool _isDealOfTheDay;
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
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.product.name);
    _descCtrl = TextEditingController(text: widget.product.description);
    _priceCtrl = TextEditingController(text: widget.product.price.toString());
    _originalPriceCtrl = TextEditingController(text: widget.product.originalPrice?.toString() ?? '');
    _quantityCtrl = TextEditingController(text: widget.product.quantity.toString());

    _existingImages = widget.product.imageUrls ?? (widget.product.imageUrl != null ? [widget.product.imageUrl!] : []);
    
    _selectedUnit = widget.product.unit;
    if (!_units.contains(_selectedUnit)) {
      _units.add(_selectedUnit);
    }
    
    _selectedCategoryId = widget.product.categoryId;
    _selectedCategoryName = widget.product.categoryName;
    _isAvailable = widget.product.isAvailable;
    _isOrganic = widget.product.isOrganic;
    _isDealOfTheDay = widget.product.isDealOfTheDay;
  }

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
    final totalImages = _existingImages.length + _selectedImages.length;
    if (totalImages >= 5) {
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
          final spaceLeft = 5 - totalImages;
          final imagesToAdd = images.take(spaceLeft).map((x) => File(x.path));
          _selectedImages.addAll(imagesToAdd);
        });
      }
    } catch (e) {
      debugPrint('Error picking images: $e');
    }
  }

  void _removeExistingImage(int index) {
    setState(() {
      _existingImages.removeAt(index);
    });
  }

  void _removeNewImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _updateProduct() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_existingImages.isEmpty && _selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please have at least one image')),
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
      List<String> finalUrls = List.from(_existingImages);
      
      // Upload new images
      for (int i = 0; i < _selectedImages.length; i++) {
        final url = await ImageService.uploadImage(
          _selectedImages[i], 
          'temp_${DateTime.now().millisecondsSinceEpoch}_$i'
        );
        if (url != null) finalUrls.add(url);
      }

      if (finalUrls.isEmpty) throw Exception('Failed to upload/keep images');

      final price = double.tryParse(_priceCtrl.text) ?? 0;
      final quantity = double.tryParse(_quantityCtrl.text) ?? 0;
      final originalPrice = _isDealOfTheDay ? double.tryParse(_originalPriceCtrl.text) : null;

      final updatedProduct = widget.product.copyWith(
        categoryId: _selectedCategoryId,
        categoryName: _selectedCategoryName,
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        price: price,
        originalPrice: originalPrice,
        isDealOfTheDay: _isDealOfTheDay,
        unit: _selectedUnit,
        quantity: quantity,
        imageUrl: finalUrls.first,
        imageUrls: finalUrls,
        isAvailable: quantity > 0 ? _isAvailable : false,
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
        title: const Text('Edit Product'),
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
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          ..._existingImages.asMap().entries.map((entry) {
                            return Stack(
                              children: [
                                Container(
                                  width: 100,
                                  margin: const EdgeInsets.only(right: 12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    image: DecorationImage(
                                      image: NetworkImage(entry.value),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 16,
                                  child: GestureDetector(
                                    onTap: () => _removeExistingImage(entry.key),
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
                          }),
                          ..._selectedImages.asMap().entries.map((entry) {
                            return Stack(
                              children: [
                                Container(
                                  width: 100,
                                  margin: const EdgeInsets.only(right: 12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    image: DecorationImage(
                                      image: FileImage(entry.value),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 16,
                                  child: GestureDetector(
                                    onTap: () => _removeNewImage(entry.key),
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
                          }),
                          if (_existingImages.length + _selectedImages.length < 5)
                            GestureDetector(
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
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Basic Info
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Product Name',
                      ),
                      validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description',
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
                              _selectedCategoryId = val!;
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
                    const SizedBox(height: 16),
                    
                    // Availability
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.outline),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SwitchListTile(
                        title: const Text(
                          'Currently Available',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                        ),
                        subtitle: const Text(
                          'Turn off if product is out of season or stock',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        value: _isAvailable,
                        activeColor: AppColors.primary,
                        onChanged: (val) => setState(() => _isAvailable = val),
                      ),
                    ),
                    const SizedBox(height: 28),

                    ElevatedButton(
                      onPressed: _isLoading ? null : _updateProduct,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Update Product'),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }
}
