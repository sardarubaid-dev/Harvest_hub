import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/product_model.dart';
import '../../services/database_service.dart';
import '../../services/location_service.dart';
import '../../core/dummy_data.dart';
import '../../core/auth_interceptor.dart';
import 'product_detail_screen.dart';
import 'farmer_profile_screen.dart';

class SearchFilterScreen extends StatefulWidget {
  final String? initialQuery;
  final String? initialCategory;

  const SearchFilterScreen({
    Key? key,
    this.initialQuery,
    this.initialCategory,
  }) : super(key: key);

  @override
  State<SearchFilterScreen> createState() => _SearchFilterScreenState();
}

class _SearchFilterScreenState extends State<SearchFilterScreen> {
  final DatabaseService _dbService = DatabaseService();
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  String _selectedCategory = 'All';
  double _maxDistanceKm = 10.0;
  String _selectedHarvestTime = 'Any Harvest Date';
  final Set<String> _selectedPractices = {};
  bool _inStockOnly = true;
  String _selectedSort = 'Distance (Nearest First)';

  final List<String> _recentSearches = [
    'Fresh Cow Milk',
    'Raw Honey',
    'Bitter Gourd',
    'Tomatoes',
    'Desi Eggs',
  ];

  final List<String> _categories = [
    'All',
    'Vegetables',
    'Fruits',
    'Dairy & Eggs',
    'Farm Honey',
    'Organic Herbs',
    'Cold Pressed Oils',
  ];

  final Set<String> _wishlistIds = {};

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
      _searchQuery = widget.initialQuery!;
    }
    if (widget.initialCategory != null) {
      _selectedCategory = widget.initialCategory!;
    }
    
    for (final p in DummyData.freshProducts) {
      if (p['isFavorite'] == true) {
        _wishlistIds.add(p['id'].toString());
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int get _activeFiltersCount {
    int count = 0;
    if (_selectedCategory != 'All') count++;
    if (_maxDistanceKm < 30.0) count++;
    if (_selectedHarvestTime != 'Any Harvest Date') count++;
    if (_selectedPractices.isNotEmpty) count += _selectedPractices.length;
    if (_inStockOnly) count++;
    return count;
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
  }

  void _onSearchSubmitted(String val) {
    setState(() {
      _searchQuery = val.trim();
      if (_searchQuery.isNotEmpty && !_recentSearches.contains(_searchQuery)) {
        _recentSearches.insert(0, _searchQuery);
        if (_recentSearches.length > 8) _recentSearches.removeLast();
      }
    });
  }

  void _toggleWishlist(String productId) {
    AuthInterceptor.executeAction(context, () {
      setState(() {
        if (_wishlistIds.contains(productId)) {
          _wishlistIds.remove(productId);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Removed from Wishlist'),
              duration: Duration(seconds: 1),
            ),
          );
        } else {
          _wishlistIds.add(productId);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Added to Wishlist'),
              duration: Duration(seconds: 1),
            ),
          );
        }
      });
    });
  }

  void _addToCart(ProductModel product) {
    AuthInterceptor.executeAction(context, () {
      final existingIndex =
          DummyData.cart.indexWhere((p) => p['id'] == product.id);
      if (existingIndex != -1) {
        DummyData.cart[existingIndex]['quantity'] =
            (DummyData.cart[existingIndex]['quantity'] as int) + 1;
      } else {
        DummyData.cart.add({
          'id': product.id,
          'title': product.name,
          'farmerName': product.farmerName ?? 'Local Farmer',
          'price': product.price.toStringAsFixed(0),
          'unit': '/ ${product.unit}',
          'quantity': 1,
          'imageUrl': product.imageUrl ?? '',
          'category': product.categoryName,
        });
      }
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added ${product.name} to Cart'),
          duration: const Duration(seconds: 2),
        ),
      );
    });
  }

  List<ProductModel> _applyFiltersAndSort(List<ProductModel> allProducts) {
    List<ProductModel> list = List.from(allProducts);

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((p) {
        final matchesName = p.name.toLowerCase().contains(q);
        final matchesDesc = p.description.toLowerCase().contains(q);
        final matchesFarmer = (p.farmerName ?? '').toLowerCase().contains(q);
        final matchesCat = p.categoryName.toLowerCase().contains(q);
        return matchesName || matchesDesc || matchesFarmer || matchesCat;
      }).toList();
    }

    if (_selectedCategory != 'All') {
      final cat = _selectedCategory.toLowerCase();
      list = list.where((p) {
        final pCat = p.categoryName.toLowerCase();
        if (cat == 'vegetables') return pCat.contains('veg');
        if (cat == 'fruits') return pCat.contains('fruit');
        if (cat == 'dairy & eggs') {
          return pCat.contains('dairy') || pCat.contains('egg') || pCat.contains('milk');
        }
        if (cat == 'farm honey') return pCat.contains('honey') || p.name.toLowerCase().contains('honey');
        if (cat == 'organic herbs') return pCat.contains('herb') || p.name.toLowerCase().contains('spinach');
        if (cat == 'cold pressed oils') return pCat.contains('oil') || p.name.toLowerCase().contains('ghee');
        return pCat == cat;
      }).toList();
    }

    if (_inStockOnly) {
      list = list.where((p) => p.isAvailable && p.quantity > 0).toList();
    }

    list = list.where((p) {
      final dist = LocationService.getDistanceForProduct(p);
      return dist <= _maxDistanceKm;
    }).toList();

    if (_selectedPractices.contains('Certified Organic')) {
      list = list.where((p) => p.isOrganic).toList();
    }

    if (_selectedSort == 'Distance (Nearest First)') {
      list = LocationService.sortByNearest(list);
    } else if (_selectedSort == 'Price (Low to High)') {
      list.sort((a, b) => a.price.compareTo(b.price));
    } else if (_selectedSort == 'Price (High to Low)') {
      list.sort((a, b) => b.price.compareTo(a.price));
    } else if (_selectedSort == 'Freshness (Harvested Today)') {
      list.sort((a, b) {
        final dateA = a.createdAt ?? DateTime.now();
        final dateB = b.createdAt ?? DateTime.now();
        return dateB.compareTo(dateA);
      });
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: StreamBuilder<List<ProductModel>>(
          stream: _dbService.streamAllProducts(),
          builder: (context, snapshot) {
            final allProducts = snapshot.data ?? DummyData.seedProducts;
            final filteredProducts = _applyFiltersAndSort(allProducts);

            return CustomScrollView(
              slivers: [
                
                SliverToBoxAdapter(
                  child: _buildHeader(),
                ),

                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StickySearchControlsDelegate(
                    child: _buildStickyControls(filteredProducts.length),
                  ),
                ),

                SliverToBoxAdapter(
                  child: _buildMatchAndSortBar(filteredProducts.length),
                ),

                if (_shouldShowFarmerMatch(filteredProducts))
                  SliverToBoxAdapter(
                    child: _buildFarmerSpotlightBanner(),
                  ),

                if (filteredProducts.isEmpty)
                  SliverToBoxAdapter(
                    child: _buildEmptyState(),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final product = filteredProducts[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: _buildProductCard(product),
                          );
                        },
                        childCount: filteredProducts.length,
                      ),
                    ),
                  ),

                if (filteredProducts.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _buildDiscoveryFooter(),
                  ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: 32),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.eco,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'HarvestHub',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    'Discovery',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_none,
                      color: AppColors.onSurfaceVariant,
                    ),
                    onPressed: () {},
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStickyControls(int matchCount) {
    final activeCount = _activeFiltersCount;

    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.search,
                        color: AppColors.primary,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) {
                            setState(() {
                              _searchQuery = val.trim();
                            });
                          },
                          onSubmitted: _onSearchSubmitted,
                          decoration: const InputDecoration(
                            hintText: 'Search farm fresh produce...',
                            hintStyle: TextStyle(
                              color: AppColors.outline,
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ),
                      if (_searchController.text.isNotEmpty)
                        GestureDetector(
                          onTap: _clearSearch,
                          child: const Icon(
                            Icons.cancel,
                            color: AppColors.onSurfaceVariant,
                            size: 18,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.tune,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      onPressed: () => _openFilterModal(matchCount),
                    ),
                  ),
                  if (activeCount > 0)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$activeCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 6),

          SizedBox(
            height: 28,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.history, size: 14, color: AppColors.outline),
                    SizedBox(width: 4),
                    Text(
                      'Recent: ',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.outline,
                      ),
                    ),
                  ],
                ),
                ..._recentSearches.map((term) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: GestureDetector(
                      onTap: () {
                        _searchController.text = term;
                        _onSearchSubmitted(term);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          term,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 6),

          SizedBox(
            height: 30,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                if (_selectedCategory != 'All')
                  _buildActiveFilterChip(
                    _selectedCategory,
                    () => setState(() => _selectedCategory = 'All'),
                  ),
                if (_maxDistanceKm < 30.0)
                  _buildActiveFilterChip(
                    '< ${_maxDistanceKm.toInt()} km',
                    () => setState(() => _maxDistanceKm = 30.0),
                  ),
                if (_inStockOnly)
                  _buildActiveFilterChip(
                    'In Stock Only',
                    () => setState(() => _inStockOnly = false),
                  ),
                ..._selectedPractices.map(
                  (p) => _buildActiveFilterChip(
                    p,
                    () => setState(() => _selectedPractices.remove(p)),
                  ),
                ),
                GestureDetector(
                  onTap: () => _openFilterModal(matchCount),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.add, size: 14, color: AppColors.primary),
                        SizedBox(width: 4),
                        Text(
                          'Filter',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 6),

          SizedBox(
            height: 34,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = cat;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFilterChip(String label, VoidCallback onRemove) {
    return Padding(
      padding: const EdgeInsets.only(right: 6.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.secondaryContainer,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.onSecondaryContainer,
              ),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onRemove,
              child: const Icon(
                Icons.close,
                size: 12,
                color: AppColors.onSecondaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchAndSortBar(int matchCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$matchCount Matches',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'near you',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.outline,
                ),
              ),
            ],
          ),
          PopupMenuButton<String>(
            initialValue: _selectedSort,
            onSelected: (val) => setState(() => _selectedSort = val),
            itemBuilder: (context) => [
              'Distance (Nearest First)',
              'Price (Low to High)',
              'Price (High to Low)',
              'Freshness (Harvested Today)',
            ].map((option) {
              return PopupMenuItem<String>(
                value: option,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      option,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: _selectedSort == option
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: _selectedSort == option
                            ? AppColors.primary
                            : AppColors.onSurface,
                      ),
                    ),
                    if (_selectedSort == option)
                      const Icon(
                        Icons.check,
                        size: 16,
                        color: AppColors.primary,
                      ),
                  ],
                ),
              );
            }).toList(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.sort,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _selectedSort.length > 20
                        ? '${_selectedSort.substring(0, 18)}...'
                        : _selectedSort,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const Icon(
                    Icons.expand_more,
                    size: 16,
                    color: AppColors.outline,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _shouldShowFarmerMatch(List<ProductModel> products) {
    
    return products.isNotEmpty;
  }

  Widget _buildFarmerSpotlightBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withOpacity(0.08),
              AppColors.secondaryContainer.withOpacity(0.25),
              Colors.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.12),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: AppColors.secondaryContainer,
                        borderRadius: BorderRadius.circular(23),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(23),
                        child: Image.network(
                          'https://images.unsplash.com/photo-1544717305-2782549b5136?q=80&w=200&auto=format&fit=crop',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.agriculture,
                            color: AppColors.primary,
                            size: 26,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Text(
                              'FARMER MATCH',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(width: 4),
                            CircleAvatar(
                              radius: 2,
                              backgroundColor: AppColors.primary,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Verified Grower',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.outline,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Green Valley Farm',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const Text(
                          'Ahmad Hassan • Malir District',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.near_me,
                        size: 13,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 3),
                      Text(
                        '2.4 km',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: const [
                          Icon(
                            Icons.eco,
                            size: 13,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '14 Active Products',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: const [
                          Icon(
                            Icons.star,
                            size: 13,
                            color: Color(0xFFD97706),
                          ),
                          SizedBox(width: 3),
                          Text(
                            '4.9 (142)',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    final farmerMap = DummyData.popularFarmers.first;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FarmerProfileScreen(farmer: farmerMap),
                      ),
                    );
                  },
                  child: Row(
                    children: const [
                      Text(
                        'View Farm Profile',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(width: 2),
                      Icon(
                        Icons.arrow_forward,
                        size: 14,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(ProductModel product) {
    final isFav = _wishlistIds.contains(product.id);
    final distanceKm = LocationService.getDistanceForProduct(product);
    final distanceLabel = LocationService.formatDistance(distanceKm);

    String originBadge = 'Harvested Yesterday';
    if (product.isOrganic) {
      originBadge = 'Pesticide-Free';
    } else if (product.name.toLowerCase().contains('honey')) {
      originBadge = '100% Raw Unfiltered';
    } else if (product.name.toLowerCase().contains('egg')) {
      originBadge = 'Free-Range Pastured';
    } else if (product.name.toLowerCase().contains('ghee') ||
        product.name.toLowerCase().contains('milk')) {
      originBadge = 'A2 Pure Desi';
    } else if (product.createdAt != null &&
        DateTime.now().difference(product.createdAt!).inHours < 12) {
      originBadge = 'Picked Today 6 AM';
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          GestureDetector(
            onTap: () => _openProductDetail(product),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: AspectRatio(
                    aspectRatio: 4 / 2.3,
                    child: product.imageUrl != null &&
                            product.imageUrl!.isNotEmpty
                        ? Image.network(
                            product.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: AppColors.surfaceContainerHigh,
                              child: const Icon(
                                Icons.eco,
                                color: AppColors.outline,
                                size: 48,
                              ),
                            ),
                          )
                        : Container(
                            color: AppColors.surfaceContainerHigh,
                            child: const Icon(
                              Icons.eco,
                              color: AppColors.outline,
                              size: 48,
                            ),
                          ),
                  ),
                ),
                
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircleAvatar(
                          radius: 3,
                          backgroundColor: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          originBadge,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.inverseSurface.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 11,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          distanceLabel,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Text(
                                product.farmerName ?? 'Green Valley Farm',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.verified,
                                size: 14,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                '• Malir',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.outline,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: isFav ? AppColors.error : AppColors.outline,
                        size: 20,
                      ),
                      onPressed: () => _toggleWishlist(product.id),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              'Rs. ${product.price.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '/ ${product.unit}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.outline,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 3,
                              backgroundColor: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              product.quantity > 0
                                  ? 'In stock (${product.quantity.toInt()} ${product.unit} left)'
                                  : 'Out of stock',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: product.quantity > 0
                          ? () => _addToCart(product)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(
                        Icons.add_shopping_cart,
                        size: 16,
                      ),
                      label: const Text(
                        'Add',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off,
                size: 48,
                color: AppColors.outline,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Produce Matches Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try adjusting your search query, increasing distance radius, or clearing active filters.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _searchQuery = '';
                  _selectedCategory = 'All';
                  _maxDistanceKm = 30.0;
                  _selectedPractices.clear();
                  _inStockOnly = false;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Reset All Filters'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscoveryFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppColors.secondaryContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.yard,
                color: AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "You've explored all local matches!",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Looking for something specific? Expand your radius or request seasonal alerts from our growers.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () {
                setState(() {
                  _maxDistanceKm = 15.0;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Radius expanded to 15 km'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: AppColors.outline),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Broaden Distance to 15 km',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openProductDetail(ProductModel product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(
          product: {
            'id': product.id,
            'title': product.name,
            'category': product.categoryName.toUpperCase(),
            'farmerName': product.farmerName ?? 'Green Valley Farm',
            'price': product.price.toStringAsFixed(0),
            'unit': '/ ${product.unit}',
            'stockBadge': '${product.quantity.toInt()} ${product.unit} available',
            'isFavorite': _wishlistIds.contains(product.id),
            'imageUrl': product.imageUrl,
            'description': product.description,
          },
        ),
      ),
    );
  }

  void _openFilterModal(int currentMatches) {
    double tempRadius = _maxDistanceKm;
    String tempHarvestTime = _selectedHarvestTime;
    final Set<String> tempPractices = Set.from(_selectedPractices);
    bool tempInStock = _inStockOnly;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            int activeInModal = 0;
            if (_selectedCategory != 'All') activeInModal++;
            if (tempRadius < 30.0) activeInModal++;
            if (tempHarvestTime != 'Any Harvest Date') activeInModal++;
            activeInModal += tempPractices.length;
            if (tempInStock) activeInModal++;

            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Filter Produce',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryContainer,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$activeInModal Active',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.onSecondaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const Divider(),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Distance Radius',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                      ),
                      Text(
                        '${tempRadius.toInt()} km',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: tempRadius,
                    min: 1,
                    max: 30,
                    divisions: 29,
                    activeColor: AppColors.primary,
                    inactiveColor: AppColors.surfaceContainerHigh,
                    onChanged: (val) {
                      setModalState(() => tempRadius = val);
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        '1 km',
                        style: TextStyle(fontSize: 10, color: AppColors.outline),
                      ),
                      Text(
                        '10 km',
                        style: TextStyle(fontSize: 10, color: AppColors.outline),
                      ),
                      Text(
                        '30 km',
                        style: TextStyle(fontSize: 10, color: AppColors.outline),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'Harvest Time',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      'Within 24 Hours',
                      'Today Only',
                      'Within 3 Days',
                      'Any Harvest Date',
                    ].map((time) {
                      final isSelected = tempHarvestTime == time;
                      return ChoiceChip(
                        label: Text(time),
                        selected: isSelected,
                        selectedColor: AppColors.secondaryContainer,
                        backgroundColor: AppColors.surfaceContainerHigh,
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? AppColors.onSecondaryContainer
                              : AppColors.onSurface,
                        ),
                        onSelected: (val) {
                          if (val) setModalState(() => tempHarvestTime = time);
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'Farming Practices',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      'Certified Organic',
                      'Pesticide-Free',
                      'Hydroponic',
                      'Heritage Seeds',
                    ].map((practice) {
                      final isSelected = tempPractices.contains(practice);
                      return FilterChip(
                        label: Text(practice),
                        selected: isSelected,
                        selectedColor: AppColors.secondaryContainer,
                        backgroundColor: AppColors.surfaceContainerHigh,
                        checkmarkColor: AppColors.primary,
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? AppColors.onSecondaryContainer
                              : AppColors.onSurface,
                        ),
                        onSelected: (val) {
                          setModalState(() {
                            if (val) {
                              tempPractices.add(practice);
                            } else {
                              tempPractices.remove(practice);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'In Stock Only',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                            ),
                          ),
                          Text(
                            'Hide sold out harvest batches',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.outline,
                            ),
                          ),
                        ],
                      ),
                      Switch(
                        value: tempInStock,
                        activeColor: AppColors.primary,
                        onChanged: (val) {
                          setModalState(() => tempInStock = val);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setModalState(() {
                              tempRadius = 30.0;
                              tempHarvestTime = 'Any Harvest Date';
                              tempPractices.clear();
                              tempInStock = false;
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Reset All'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _maxDistanceKm = tempRadius;
                              _selectedHarvestTime = tempHarvestTime;
                              _selectedPractices.clear();
                              _selectedPractices.addAll(tempPractices);
                              _inStockOnly = tempInStock;
                            });
                            Navigator.pop(ctx);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Apply Filters',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _StickySearchControlsDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickySearchControlsDelegate({required this.child});

  @override
  double get minExtent => 164.0;
  @override
  double get maxExtent => 164.0;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _StickySearchControlsDelegate oldDelegate) {
    return true;
  }
}
