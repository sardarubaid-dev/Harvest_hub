import 'package:flutter/material.dart';
import '../../models/category_model.dart';
import '../../services/database_service.dart';
import '../../theme/app_theme.dart';

class FarmerCategoriesScreen extends StatefulWidget {
  final bool isSelectionMode;
  final String? selectedCategoryId;

  const FarmerCategoriesScreen({
    super.key,
    this.isSelectionMode = false,
    this.selectedCategoryId,
  });

  @override
  State<FarmerCategoriesScreen> createState() => _FarmerCategoriesScreenState();
}

class _FarmerCategoriesScreenState extends State<FarmerCategoriesScreen> {
  final DatabaseService _dbService = DatabaseService();
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  IconData _getCategoryIcon(String categoryName) {
    final lower = categoryName.toLowerCase();
    if (lower.contains('fruit')) return Icons.apple;
    if (lower.contains('veg')) return Icons.eco;
    if (lower.contains('dairy') || lower.contains('milk')) return Icons.water_drop;
    if (lower.contains('organic')) return Icons.spa;
    if (lower.contains('grain') || lower.contains('pulse') || lower.contains('wheat')) {
      return Icons.grass;
    }
    if (lower.contains('herb') || lower.contains('spice')) return Icons.local_florist;
    if (lower.contains('honey')) return Icons.hive;
    if (lower.contains('meat') || lower.contains('poultry')) return Icons.set_meal;
    return Icons.category_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          widget.isSelectionMode ? 'Select Category' : 'Product Categories',
          style: const TextStyle(
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
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            color: AppColors.surface,
            child: TextField(
              controller: _searchCtrl,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.trim().toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search categories...',
                prefixIcon: const Icon(Icons.search, color: AppColors.outline),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.outline),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                fillColor: AppColors.surfaceContainerLow,
              ),
            ),
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.surfaceVariant),
          Expanded(
            child: StreamBuilder<List<CategoryModel>>(
              stream: _dbService.streamCategories(),
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
                          'Error loading categories',
                          style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                final allCategories = snapshot.data ?? [];
                final filtered = allCategories.where((c) {
                  if (_searchQuery.isEmpty) return true;
                  return c.name.toLowerCase().contains(_searchQuery);
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.category_outlined, size: 60, color: AppColors.outline),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'No categories match "$_searchQuery"'
                              : 'No categories available',
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final category = filtered[index];
                    final isSelected = widget.selectedCategoryId == category.id;

                    return InkWell(
                      onTap: () {
                        if (widget.isSelectionMode) {
                          Navigator.pop(context, category);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Selected category: ${category.name}'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        }
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.onTertiaryContainer
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.surfaceVariant,
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0A000000),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary.withValues(alpha: 0.15)
                                    : AppColors.surfaceContainerLow,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _getCategoryIcon(category.name),
                                size: 28,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                category.name,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.onSurface,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (widget.isSelectionMode) ...[
                              const SizedBox(height: 6),
                              Text(
                                isSelected ? 'Selected' : 'Tap to select',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight:
                                      isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.outline,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
