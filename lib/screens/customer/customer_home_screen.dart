import 'package:flutter/material.dart';

import '../../widgets/harvi_avatar.dart';
import 'chatbot_screen.dart';

import 'package:provider/provider.dart';

import 'dart:async';
import 'orders_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';
import 'farmer_profile_screen.dart';
import 'search_filter_screen.dart';
import '../../models/product_model.dart';
import '../../models/category_model.dart';
import '../../models/farmer_model.dart';
import '../../providers/cart_provider.dart';
import '../../services/database_service.dart';
import '../../services/location_service.dart';
import '../../core/auth_interceptor.dart';
import '../../providers/auth_provider.dart';
import 'product_detail_screen.dart';
import 'categories_screen.dart';
import 'products_screen.dart';
import 'wishlist_screen.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({Key? key}) : super(key: key);

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  int _currentIndex = 0;
  String _selectedCategoryId = '1';
  String _selectedGlobalCategory = 'All';

  final DatabaseService _dbService = DatabaseService();
  StreamSubscription<List<ProductModel>>? _productsSub;

  late List<Map<String, dynamic>> _freshProducts = [];
  late List<Map<String, dynamic>> _popularFarmers = [];
  late List<Map<String, dynamic>> _recentlyRestocked = [];
  List<CategoryModel> _categories = [];
  StreamSubscription<List<CategoryModel>>? _categoriesSub;
  StreamSubscription<List<FarmerModel>>? _farmersSub;

  final List<Map<String, dynamic>> _customerReviews = [
    {
      'name': 'Ayesha Khan',
      'location': 'DHA Phase 6, Karachi',
      'rating': 5,
      'date': 'Yesterday',
      'avatar':
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=200&auto=format&fit=crop',
      'review':
          'The beefsteak tomatoes and spinach were harvested the exact same morning! Unmatched freshness compared to standard supermarket produce.',
      'product': 'Fresh Tomatoes',
      'farm': 'Green Valley Farm',
    },
    {
      'name': 'Farhan Siddiqui',
      'location': 'Clifton, Karachi',
      'rating': 5,
      'date': '2 days ago',
      'avatar':
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=200&auto=format&fit=crop',
      'review':
          'Pure desi cow ghee delivered directly from Meadow Dairy. The aroma and authentic texture are phenomenal. Highly recommended app!',
      'product': 'Desi Cow Ghee',
      'farm': 'Meadow Dairy Farm',
    },
    {
      'name': 'Dr. Tariq Mehmood',
      'location': 'Gulshan-e-Iqbal',
      'rating': 5,
      'date': '4 days ago',
      'avatar':
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=200&auto=format&fit=crop',
      'review':
          'Finally a marketplace where I can trace produce back to the actual verified grower. Great pricing with zero middleman markup.',
      'product': 'Wild Blossom Honey',
      'farm': 'Potohar Apiaries',
    },
    {
      'name': 'Zainab Fatima',
      'location': 'Malir Cantt',
      'rating': 5,
      'date': '1 week ago',
      'avatar':
          'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?q=80&w=200&auto=format&fit=crop',
      'review':
          'Scheduled market pickup at Karachi Farmers Market was ready right on time. Love supporting our regional Pakistani farmers.',
      'product': 'Free-Range Eggs',
      'farm': 'Al-Barakah Farm',
    },
  ];

  Timer? _countdownTimer;
  Duration _dealRemainingTime =
      const Duration(hours: 12, minutes: 36, seconds: 24);

  final List<Map<String, dynamic>> _dealsOfTheDay = [
    {
      'id': 'deal_1',
      'title': 'Fresh Tomatoes',
      'category': 'VEGETABLES',
      'farmerName': 'Green Valley Farm',
      'price': '220',
      'originalPrice': '280',
      'discountBadge': '21% OFF',
      'unit': '1 kg',
      'stockBadge': 'Deal of the Day',
      'isFavorite': false,
      'imageColor': const Color(0xFFFFEBEE),
      'imageUrl':
          'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?q=80&w=400&auto=format&fit=crop',
    },
    {
      'id': 'deal_2',
      'title': 'Farm Avocados',
      'category': 'FRUITS',
      'farmerName': 'Sunburst Orchards',
      'price': '380',
      'originalPrice': '500',
      'discountBadge': '24% OFF',
      'unit': '4 pcs',
      'stockBadge': 'Deal of the Day',
      'isFavorite': false,
      'imageColor': const Color(0xFFE8F5E9),
      'imageUrl':
          'https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?q=80&w=400&auto=format&fit=crop',
    },
    {
      'id': 'deal_3',
      'title': 'Desi Paneer Cheese',
      'category': 'DAIRY',
      'farmerName': 'Meadow Dairy Farm',
      'price': '290',
      'originalPrice': '390',
      'discountBadge': '25% OFF',
      'unit': '200 g',
      'stockBadge': 'Deal of the Day',
      'isFavorite': false,
      'imageColor': const Color(0xFFFFF8E1),
      'imageUrl':
          'https://images.unsplash.com/photo-1631452180519-c014fe946bc7?q=80&w=400&auto=format&fit=crop',
    },
    {
      'id': 'deal_4',
      'title': 'Wild Blossom Honey',
      'category': 'ORGANIC',
      'farmerName': 'Potohar Apiaries',
      'price': '750',
      'originalPrice': '950',
      'discountBadge': '21% OFF',
      'unit': '500 g',
      'stockBadge': 'Deal of the Day',
      'isFavorite': false,
      'imageColor': const Color(0xFFFFF3E0),
      'imageUrl':
          'https://images.unsplash.com/photo-1587049352846-4a222e784d38?q=80&w=400&auto=format&fit=crop',
    },
  ];

  StreamSubscription<List<Map<String, dynamic>>>? _cartSub;
  StreamSubscription<dynamic>? _farmersSub;
  StreamSubscription<dynamic>? _reviewsSub;

  String? get _currentUid {
    try {
      final authProv = Provider.of<AuthProvider>(context, listen: false);
      if (authProv.currentUser != null && authProv.currentUser!.uid.isNotEmpty) {
        return authProv.currentUser!.uid;
      }
    } catch (_) {}
    return null;
  }

  @override
  void initState() {
    super.initState();
    
    // Start live deals countdown timer
    _startCountdownTimer();
    
    _categoriesSub = _dbService.streamCategories().listen((categories) {
      if (!mounted) return;
      setState(() => _categories = categories);
    });

    _farmersSub = _dbService.streamAllFarmers().listen((farmers) {
      if (!mounted) return;
      setState(() {
        _popularFarmers = farmers.map((f) => {
          'id': f.id,
          'name': f.farmName,
          'location': f.location,
          'rating': 5.0,
          'image': f.profileImageUrl ?? '',
          'isFollowing': false,
          'model': f,
        }).toList();
      });
    });
    _startCountdownTimer();

    // 1. Stream live Cart from Firestore ('carts' collection)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _cartSub = _dbService.streamCart(_currentUid).listen((cartItems) {
        if (!mounted) return;
        setState(() {
          DummyData.cart
            ..clear()
            ..addAll(cartItems);
        });
      });
    });

    // 2. Stream live Products from Firestore ('products' collection)
    _productsSub = _dbService.streamAllProducts().listen((products) {
      if (!mounted) return;
      _updateProductsFromStream(products);
    });

    // 3. Stream live Farmers from Firestore ('farmers' collection)
    _farmersSub = _dbService.streamAllFarmers().listen((farmers) {
      if (!mounted || farmers.isEmpty) return;
      setState(() {
        _popularFarmers = farmers.map((f) {
          return {
            'id': f.id,
            'name': f.farmName.isNotEmpty ? f.farmName : 'Verified Local Farm',
            'specialty': f.description.isNotEmpty
                ? f.description
                : 'Fresh Regional Produce',
            'location': f.location.isNotEmpty ? f.location : 'Pakistan',
            'rating': f.rating.toStringAsFixed(1),
            'reviews': '(Verified)',
            'isVerified': f.isApproved,
            'isFollowing': false,
            'avatarColor': const Color(0xFFA5D6A7),
            'imageUrl': f.profileImageUrl ?? '',
          };
        }).toList();
      });
    });

    // 4. Stream live Reviews from Firestore ('reviews' collection)
    _reviewsSub = _dbService.streamAllReviews().listen((reviews) {
      if (!mounted || reviews.isEmpty) return;
      setState(() {
        _customerReviews
          ..clear()
          ..addAll(
            reviews.map((r) {
              return {
                'name': r.customerName.isNotEmpty ? r.customerName : 'Verified Buyer',
                'location': 'Verified Order',
                'rating': r.rating.round().clamp(1, 5),
                'date': 'Recent',
                'avatar':
                    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=200&auto=format&fit=crop',
                'review': r.comment,
                'product': 'Farm Fresh Produce',
                'farm': 'HarvestHub Partner Farm',
              };
            }),
          );
      });
    });
  }

  void _startCountdownTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_dealRemainingTime.inSeconds > 0) {
        setState(() {
          _dealRemainingTime -= const Duration(seconds: 1);
        });
      } else {
        _countdownTimer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _productsSub?.cancel();
    _categoriesSub?.cancel();
    _farmersSub?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _updateProductsFromStream(List<ProductModel> products) {
    if (products.isEmpty) return;

    final sorted = LocationService.sortByNearest(products);

    final mappedProducts = sorted.map((p) {
      final dist = LocationService.getDistanceForProduct(p);
      return {
        'id': p.id,
        'farmerId': p.farmerId,
        'title': p.name,
        'category': p.categoryName.isNotEmpty
            ? p.categoryName.toUpperCase()
            : 'PRODUCE',
        'farmerName': p.farmerName ?? 'Green Valley Farm',
        'price': p.price.toStringAsFixed(0),
        'unit': '/ ${p.unit}',
        'stockBadge': '${p.quantity.toInt()} ${p.unit} available',
        'isFavorite': false,
        'imageColor': _getColorForCategory(p.categoryName),
        'imageUrl': p.imageUrl ?? '',
        'distance': LocationService.formatDistance(dist),
        'isOrganic': p.isOrganic,
        'description': p.description,
      };
    }).toList();

    setState(() {
      _freshProducts = mappedProducts;

      // Sync global DummyData.freshProducts so ProductsScreen & CategoriesScreen also use live Firestore data
      DummyData.freshProducts
        ..clear()
        ..addAll(mappedProducts);

      // Dynamically derive Recently Restocked from live in-stock Firestore products
      _recentlyRestocked = mappedProducts.reversed.take(6).map((item) {
        return {
          'id': p.id,
          'title': p.name,
          'category': p.categoryName.isNotEmpty
              ? p.categoryName.toUpperCase()
              : 'PRODUCE',
          'farmerName': p.farmerName ?? 'Green Valley Farm',
          'price': p.price.toStringAsFixed(0),
          'unit': '/ ${p.unit}',
          'stockBadge': '${p.quantity.toInt()} ${p.unit} available',
          'isFavorite': false,
          'imageColor': _getColorForCategory(p.categoryName),
          'imageUrl': p.imageUrl ?? '',
          'distance': LocationService.formatDistance(dist),
          'isOrganic': p.isOrganic,
          'description': p.description,
          'model': p,
        };
      }).toList();
      
      _recentlyRestocked = List.from(_freshProducts);
    });
  }

  Color _getColorForCategory(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('fruit') || cat.contains('apple') || cat.contains('tomato')) {
      return const Color(0xFFEF9A9A);
    }
    if (cat.contains('veg') || cat.contains('spinach')) {
      return const Color(0xFFA5D6A7);
    }
    if (cat.contains('dairy') || cat.contains('milk') || cat.contains('ghee')) {
      return const Color(0xFFD7CCC8);
    }
    if (cat.contains('honey')) {
      return const Color(0xFFFFE082);
    }
    return const Color(0xFF81C784);
  }

  IconData _getIconForCategoryName(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('veg')) return Icons.eco;
    if (lowerName.contains('fruit')) return Icons.apple;
    if (lowerName.contains('dairy') || lowerName.contains('egg')) return Icons.water_drop;
    if (lowerName.contains('honey')) return Icons.hive;
    if (lowerName.contains('herb')) return Icons.local_florist;
    if (lowerName.contains('oil')) return Icons.opacity;
    if (lowerName.contains('grain') || lowerName.contains('pulse')) return Icons.grass;
    if (lowerName.contains('meat') || lowerName.contains('poultry')) return Icons.set_meal;
    return Icons.apps;
  }

  void _toggleFavorite(List<Map<String, dynamic>> list, int index) {
    AuthInterceptor.executeAction(context, () async {
      final bool nextState = !(list[index]['isFavorite'] as bool);
      setState(() {
        list[index]['isFavorite'] = nextState;
      });
      final String? uid = _currentUid;
      final String prodId = (list[index]['id'] ?? '').toString();
      if (uid != null && prodId.isNotEmpty) {
        await _dbService.toggleWishlistProduct(uid, prodId);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            nextState ? 'Added to Wishlist' : 'Removed from Wishlist',
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    });
  }

  void _addToCart(Map<String, dynamic> product) {
    AuthInterceptor.executeAction(context, () {
      if (product['model'] != null) {
        Provider.of<CartProvider>(context, listen: false).addItem(product['model'] as ProductModel);
      }
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Added to Cart!')));
    });
  }

  void _toggleFollow(int index) {
    final bool nextFollow = !(_popularFarmers[index]['isFollowing'] as bool);
    setState(() {
      _popularFarmers[index]['isFollowing'] = nextFollow;
    });
    final String? uid = _currentUid;
    final String farmerId = (_popularFarmers[index]['id'] ?? '').toString();
    if (uid != null && farmerId.isNotEmpty) {
      _dbService.toggleFollowFarmer(uid, farmerId);
    }
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          nextFollow
              ? 'Following ${_popularFarmers[index]['name']}'
              : 'Unfollowed ${_popularFarmers[index]['name']}',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userName = authProvider.currentUser?.name ?? 'Guest User';

    const Color primaryGreen = Color(0xFF2E7D32);
    const Color darkText = Color(0xFF1F2937);
    const Color greyText = Color(0xFF6B7280);
    const Color background = Color(0xFFF9FBF9);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        top: _currentIndex != 0,
        child: Column(
          children: [
            if (_currentIndex != 0 && _currentIndex != 5)
              _buildGlobalHeader(primaryGreen, darkText, greyText, userName),
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: [
                  _buildHomeTab(primaryGreen, darkText, greyText, userName),
                  ProductsScreen(initialCategory: _selectedGlobalCategory),
                  CategoriesScreen(
                    onCategorySelected: (category) {
                      setState(() {
                        _selectedGlobalCategory = category;
                        _currentIndex = 1; 
                      });
                    },
                  ),
                  const WishlistScreen(),
                  OrdersScreen(
                    onShopNow: () {
                      setState(() {
                        _selectedGlobalCategory = 'All';
                        _currentIndex = 1; 
                      });
                    },
                  ),
                  const ProfileScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: GestureDetector(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 20,
              ),
              child: const ChatbotScreen(),
            ),
          );
        },
        child: Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(shape: BoxShape.circle),
          child: const HarviAvatar(expression: HarviExpression.idle, size: 80),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryGreen,
        unselectedItemColor: greyText,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront_outlined),
            activeIcon: Icon(Icons.storefront),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'Wishlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildGlobalHeader(
    Color primaryGreen,
    Color darkText,
    Color greyText,
    String userName,
  ) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: primaryGreen,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.eco, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'HarvestHub',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: darkText,
                      height: 1.0,
                    ),
                  ),
                  Text(
                    'LOCAL FARM MARKETPLACE',
                    style: TextStyle(
                      fontSize: 6,
                      fontWeight: FontWeight.bold,
                      color: greyText,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  'WELCOME',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: primaryGreen,
                    letterSpacing: 1.0,
                  ),
                ),
                Text(
                  userName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: darkText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.search, color: darkText, size: 24),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SearchFilterScreen(),
                    ),
                  );
                },
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartScreen()),
                  ).then((_) => setState(() {}));
                },
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      Icons.shopping_bag_outlined,
                      color: darkText,
                      size: 24,
                    ),
                    Consumer<CartProvider>(
                      builder: (context, cart, child) {
                        if (cart.itemCount == 0) return const SizedBox.shrink();
                        return Positioned(
                          top: -4,
                          right: -4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: primaryGreen,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${cart.itemCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () => setState(() => _currentIndex = 5), 
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: primaryGreen.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.person, color: primaryGreen, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildHomeTab(
    Color primaryGreen,
    Color darkText,
    Color greyText,
    String userName,
  ) {
    final topPadding = MediaQuery.of(context).padding.top;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        SliverPersistentHeader(
          pinned: true,
          delegate: _CustomerHomeHeaderDelegate(
            topPadding: topPadding,
            primaryGreen: primaryGreen,
            darkText: darkText,
            greyText: greyText,
            userName: userName,
            onCartTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartScreen()),
              ).then((_) => setState(() {}));
            },
            onProfileTap: () => setState(() => _currentIndex = 5),
            onSearchTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SearchFilterScreen(),
                ),
              );
            },
          ),
        ),
        SliverToBoxAdapter(
          child: Container(
            color: const Color(0xFFF9FBF9),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),

                // Explore Categories Showcase Section
                _buildCategoriesShowcase(primaryGreen, darkText, greyText),

          const SizedBox(height: 24),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Icon(Icons.filter_list, size: 16, color: primaryGreen),
                const SizedBox(width: 6),
                Text(
                  'Quick Filter',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: darkText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  final isSelected = _selectedCategoryId == '1';
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedCategoryId = '1');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? primaryGreen : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? Colors.transparent
                                : const Color(0xFFE5E7EB),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.apps,
                              size: 16,
                              color: isSelected ? Colors.white : primaryGreen,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'All',
                              style: TextStyle(
                                color: isSelected ? Colors.white : darkText,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                
                final cat = _categories[index - 1];
                final isSelected = _selectedCategoryId == cat.id;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _selectedCategoryId = cat.id);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? primaryGreen : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : const Color(0xFFE5E7EB),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _getIconForCategoryName(cat.name),
                            size: 16,
                            color: isSelected ? Colors.white : primaryGreen,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            cat.name,
                            style: TextStyle(
                              color: isSelected ? Colors.white : darkText,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          _buildSectionHeader('Fresh Near You', 'Today'),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _freshProducts
                  .where(
                    (p) =>
                        _selectedCategoryId == '1' ||
                        p['category'].toString().toLowerCase() ==
                            _categories
                                .firstWhere(
                                  (c) => c.id == _selectedCategoryId,
                                  orElse: () => CategoryModel(id: '', name: ''),
                                ).name
                                .toLowerCase(),
                  )
                  .toList()
                  .length,
              itemBuilder: (context, index) {
                final filteredList = _freshProducts
                    .where(
                      (p) =>
                          _selectedCategoryId == '1' ||
                          p['category'].toString().toLowerCase() ==
                              _categories
                                  .firstWhere(
                                    (c) => c.id == _selectedCategoryId,
                                    orElse: () => CategoryModel(id: '', name: ''),
                                  ).name
                                  .toLowerCase(),
                    )
                    .toList();

                if (filteredList.isEmpty) return const SizedBox();

                return Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: _buildProductCard(
                    data: filteredList[index],
                    onFavoriteTap: () {
                      final originalIndex = _freshProducts.indexWhere(
                        (element) => element['id'] == filteredList[index]['id'],
                      );
                      _toggleFavorite(_freshProducts, originalIndex);
                    },
                    onAddTap: () => _addToCart(filteredList[index]),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // Offers Banner Carousel
          _buildOffersCarousel(),

          const SizedBox(height: 24),

          // Deals Of The Day Section
          _buildDealsOfTheDaySection(primaryGreen, darkText, greyText),

          const SizedBox(height: 24),

          // Popular Farmers
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Popular Farmers',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: darkText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Verified growers with highest community ratings',
                      style: TextStyle(fontSize: 12, color: greyText),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () {},
                  child: Row(
                    children: [
                      Text(
                        'Explore',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: primaryGreen,
                        ),
                      ),
                      Icon(Icons.chevron_right, color: primaryGreen, size: 18),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _popularFarmers.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: _buildFarmerCard(
                    data: _popularFarmers[index],
                    onFollowTap: () => _toggleFollow(index),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          _buildSectionHeader('Recently Restocked', 'New Batch'),
          const SizedBox(height: 16),
          SizedBox(
            height: 260,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _recentlyRestocked.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: _buildProductCard(
                    data: _recentlyRestocked[index],
                    onFavoriteTap: () =>
                        _toggleFavorite(_recentlyRestocked, index),
                    onAddTap: () => _addToCart(_recentlyRestocked[index]),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 28),

          _buildCustomerReviewsSection(primaryGreen, darkText, greyText),

          const SizedBox(height: 28),

          _buildHarvestHubGuaranteeSection(primaryGreen, darkText, greyText),

          const SizedBox(height: 28),

          _buildCommunityStatsSection(primaryGreen, darkText, greyText),

          const SizedBox(height: 24),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF2FDF5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xFF81C784),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.energy_savings_leaf,
                      color: Color(0xFF2E7D32),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '100% Direct-from-Farm',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: darkText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Your orders directly empower sustainable regional farmers and promote organic soil revitalization.',
                          style: TextStyle(
                            fontSize: 12,
                            color: greyText,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOffersCarousel() {
    final offers = [
      {
        'title': 'Fresh Fruits',
        'subtitle': 'Up to 30% Off',
        'buttonText': 'Shop Now',
        'buttonBg': const Color(0xFF0F4722),
        'buttonTextColor': Colors.white,
        'titleColor': const Color(0xFF1E5224),
        'subtitleColor': const Color(0xFF27672F),
        'bgGradient': const LinearGradient(
          colors: [Color(0xFFD6F0BA), Color(0xFFAFE08C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        'imageUrl':
            'https://images.unsplash.com/photo-1619566636858-adf3ef46400b?q=80&w=400&auto=format&fit=crop',
        'category': 'Fruits',
        'hasSeal': false,
      },
      {
        'title': 'Daily Essentials',
        'subtitle': 'Better Prices\nEvery Day',
        'buttonText': 'Shop Now',
        'buttonBg': Colors.white,
        'buttonTextColor': const Color(0xFFE65100),
        'titleColor': Colors.white,
        'subtitleColor': Colors.white,
        'bgGradient': const LinearGradient(
          colors: [Color(0xFFFA7E23), Color(0xFFF35B10)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        'imageUrl':
            'https://images.unsplash.com/photo-1588964895597-cfccd6e2dbf9?q=80&w=400&auto=format&fit=crop',
        'category': 'All',
        'hasSeal': false,
      },
      {
        'title': 'Organic Products',
        'subtitle': 'Pure & Natural',
        'buttonText': 'Shop Now',
        'buttonBg': Colors.white,
        'buttonTextColor': const Color(0xFF1B3D52),
        'titleColor': Colors.white,
        'subtitleColor': const Color(0xFFE2E8F0),
        'bgGradient': const LinearGradient(
          colors: [Color(0xFF23445A), Color(0xFF172E3D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        'imageUrl':
            'https://images.unsplash.com/photo-1540420773420-3366772f4999?q=80&w=400&auto=format&fit=crop',
        'category': 'All',
        'hasSeal': true,
      },
    ];

    return SizedBox(
      height: 155,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: offers.length,
        itemBuilder: (context, index) {
          final offer = offers[index];
          final gradient = offer['bgGradient'] as LinearGradient;

          return Container(
            width: 260,
            margin: const EdgeInsets.only(right: 14),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  // Right-side image with clean alpha ShaderMask
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    width: 135,
                    child: ShaderMask(
                      shaderCallback: (rect) {
                        return const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.transparent,
                            Colors.white,
                          ],
                          stops: [0.0, 0.45],
                        ).createShader(rect);
                      },
                      blendMode: BlendMode.dstIn,
                      child: Image.network(
                        offer['imageUrl'] as String,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.black12,
                          child: const Icon(
                            Icons.image,
                            color: Colors.white54,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Left-side content
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: 145,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 6, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            offer['title'] as String,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: offer['titleColor'] as Color,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            offer['subtitle'] as String,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: offer['subtitleColor'] as Color,
                              height: 1.25,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedGlobalCategory =
                                    offer['category'] as String;
                                _currentIndex = 1; // Products tab
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color: offer['buttonBg'] as Color,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.12),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    offer['buttonText'] as String,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          offer['buttonTextColor'] as Color,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.arrow_forward,
                                    size: 12,
                                    color:
                                        offer['buttonTextColor'] as Color,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 100% Organic seal badge on Card 3
                  if (offer['hasSeal'] == true)
                    Positioned(
                      right: 10,
                      bottom: 10,
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B5E20),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFFFD54F),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.35),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.eco, size: 9, color: Color(0xFFFFD54F)),
                            Text(
                              '100%',
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                height: 1.0,
                              ),
                            ),
                            Text(
                              'Organic',
                              style: TextStyle(
                                fontSize: 6,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFFD54F),
                                height: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDealsOfTheDaySection(
    Color primaryGreen,
    Color darkText,
    Color greyText,
  ) {
    final hoursStr = _dealRemainingTime.inHours.toString().padLeft(2, '0');
    final minsStr =
        (_dealRemainingTime.inMinutes % 60).toString().padLeft(2, '0');
    final secsStr =
        (_dealRemainingTime.inSeconds % 60).toString().padLeft(2, '0');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header with Countdown Timer & View All
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Deals Of The Day',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: darkText,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _buildTimerPill('$hoursStr Hours'),
                      const SizedBox(width: 4),
                      _buildTimerPill('$minsStr Mins'),
                      const SizedBox(width: 4),
                      _buildTimerPill('$secsStr Secs'),
                    ],
                  ),
                ],
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SearchFilterScreen(),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Text(
                      'View All Deals',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: primaryGreen,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: primaryGreen,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Deal Cards Horizontal List
        SizedBox(
          height: 295,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _dealsOfTheDay.length,
            itemBuilder: (context, index) {
              final deal = _dealsOfTheDay[index];
              return Container(
                width: 185,
                margin: const EdgeInsets.only(right: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE53935),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(
                                Icons.local_fire_department,
                                color: Colors.white,
                                size: 11,
                              ),
                              SizedBox(width: 2),
                              Text(
                                'Deal',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEBEE),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            deal['discountBadge'] ?? '',
                            style: const TextStyle(
                              color: Color(0xFFC62828),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Product Image
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProductDetailScreen(product: deal),
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          height: 115,
                          width: double.infinity,
                          color: deal['imageColor'] as Color? ??
                              const Color(0xFFF9FAFB),
                          child: Image.network(
                            deal['imageUrl'] as String,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Center(
                              child: Icon(
                                Icons.image,
                                size: 36,
                                color: Colors.black26,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Title
                    Text(
                      deal['title'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: darkText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),

                    // Unit & Farmer
                    Text(
                      '${deal['unit']} • ${deal['farmerName']}',
                      style: TextStyle(
                        fontSize: 11,
                        color: greyText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),

                    // Price Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          'Rs. ${deal['price']}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFD32F2F),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Rs. ${deal['originalPrice']}',
                          style: const TextStyle(
                            fontSize: 11,
                            decoration: TextDecoration.lineThrough,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Add to Cart Button
                    SizedBox(
                      width: double.infinity,
                      height: 34,
                      child: ElevatedButton(
                        onPressed: () => _addToCart(deal),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D631B),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.add_shopping_cart,
                              size: 13,
                              color: Colors.white,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'Add to Cart',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTimerPill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF1B5E20),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildCategoriesShowcase(
    Color primaryGreen,
    Color darkText,
    Color greyText,
  ) {
    final homeCategories = [
      {
        'name': 'Fruits &\nVegetables',
        'targetCategory': 'Vegetables',
        'bgColor': const Color(0xFFEFF7E3),
        'asset': 'assets/images/cat_fruits_veg.png',
      },
      {
        'name': 'Dairy & Eggs',
        'targetCategory': 'Dairy & Eggs',
        'bgColor': const Color(0xFFE8F4F9),
        'asset': 'assets/images/cat_dairy_eggs.png',
      },
      {
        'name': 'Bakery & Bread',
        'targetCategory': 'Grains & Pulses',
        'bgColor': const Color(0xFFFCF1E6),
        'asset': 'assets/images/cat_bakery.png',
      },
      {
        'name': 'Meat & Seafood',
        'targetCategory': 'Meat & Poultry',
        'bgColor': const Color(0xFFFDEDEC),
        'asset': 'assets/images/cat_meat.png',
      },
      {
        'name': 'Pantry Staples',
        'targetCategory': 'Cold Pressed Oils',
        'bgColor': const Color(0xFFEFF6EA),
        'asset': 'assets/images/cat_staples.png',
      },
      {
        'name': 'Snacks &\nBeverages',
        'targetCategory': 'All',
        'bgColor': const Color(0xFFE8F7FC),
        'asset': 'assets/images/cat_beverages.png',
      },
      {
        'name': 'Household',
        'targetCategory': 'All',
        'bgColor': const Color(0xFFECF4F7),
        'asset': 'assets/images/cat_household.png',
      },
      {
        'name': 'Personal Care',
        'targetCategory': 'Organic Herbs',
        'bgColor': const Color(0xFFFFF1E6),
        'asset': 'assets/images/cat_personal.png',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Shop by Category',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: darkText,
                ),
              ),
              InkWell(
                onTap: () {
                  setState(() => _currentIndex = 2); // Switch to Categories tab
                },
                child: Row(
                  children: [
                    Text(
                      'View All',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: primaryGreen,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward, color: primaryGreen, size: 13),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: homeCategories.length,
            itemBuilder: (context, index) {
              final cat = homeCategories[index];
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedGlobalCategory =
                          cat['targetCategory'] as String;
                      _currentIndex = 1; // Switch to Products tab
                    });
                  },
                  child: Container(
                    width: 76,
                    decoration: BoxDecoration(
                      color: cat['bgColor'] as Color,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 48,
                          height: 48,
                          child: Image.asset(
                            cat['asset'] as String,
                            fit: BoxFit.contain,
                          ),
                        ),
                        Text(
                          cat['name'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2937),
                            height: 1.15,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerReviewsSection(
    Color primaryGreen,
    Color darkText,
    Color greyText,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Community Reviews',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: darkText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Real experiences from customers & families',
                    style: TextStyle(fontSize: 12, color: greyText),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.star, color: Color(0xFFD97706), size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '4.9 (420+)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: darkText,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 175,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _customerReviews.length,
            itemBuilder: (context, index) {
              final rev = _customerReviews[index];
              return Padding(
                padding: const EdgeInsets.only(right: 14.0),
                child: Container(
                  width: 270,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: const Color(0xFFE8F5E9),
                            backgroundImage:
                                NetworkImage(rev['avatar'] as String),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        rev['name'] as String,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: darkText,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const Icon(
                                      Icons.verified,
                                      size: 13,
                                      color: Color(0xFF2E7D32),
                                    ),
                                  ],
                                ),
                                Text(
                                  rev['location'] as String,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: greyText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: List.generate(
                          rev['rating'] as int,
                          (i) => const Icon(
                            Icons.star,
                            color: Color(0xFFD97706),
                            size: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Expanded(
                        child: Text(
                          rev['review'] as String,
                          style: TextStyle(
                            fontSize: 11,
                            color: darkText,
                            height: 1.35,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            rev['product'] as String,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: primaryGreen,
                            ),
                          ),
                          Text(
                            rev['date'] as String,
                            style: TextStyle(
                              fontSize: 10,
                              color: greyText,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHarvestHubGuaranteeSection(
    Color primaryGreen,
    Color darkText,
    Color greyText,
  ) {
    final guarantees = [
      {
        'icon': Icons.agriculture,
        'title': '100% Direct Farm Gate',
        'desc': 'Zero middlemen. Fair prices for growers and buyers.',
      },
      {
        'icon': Icons.schedule,
        'title': 'Same-Day Harvest',
        'desc': 'Picked within 24 hours of fulfillment.',
      },
      {
        'icon': Icons.pest_control,
        'title': 'Pesticide-Free Standard',
        'desc': 'Natural organic cultivation and pure testing.',
      },
      {
        'icon': Icons.handshake,
        'title': 'Community Impact',
        'desc': 'Empowering sustainable local Pakistani farmers.',
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'The HarvestHub Promise',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: darkText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Built on trust, freshness, and local community solidarity',
            style: TextStyle(fontSize: 12, color: greyText),
          ),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: guarantees.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.45,
            ),
            itemBuilder: (context, index) {
              final g = guarantees[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      g['icon'] as IconData,
                      color: primaryGreen,
                      size: 24,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      g['title'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: darkText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      g['desc'] as String,
                      style: TextStyle(
                        fontSize: 10,
                        color: greyText,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityStatsSection(
    Color primaryGreen,
    Color darkText,
    Color greyText,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('45+', 'Verified Farms', primaryGreen, darkText),
            Container(width: 1, height: 36, color: const Color(0xFFA5D6A7)),
            _buildStatItem('12,000+ kg', 'Harvested', primaryGreen, darkText),
            Container(width: 1, height: 36, color: const Color(0xFFA5D6A7)),
            _buildStatItem('100%', 'Direct Payouts', primaryGreen, darkText),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String value,
    String label,
    Color primaryGreen,
    Color darkText,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: primaryGreen,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: darkText,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, String badge) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFA5D6A7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ),
            ],
          ),
          InkWell(
            onTap: () {
              setState(() {
                _selectedGlobalCategory = 'All';
                _currentIndex = 1;
              });
            },
            child: Row(
              children: const [
                Text(
                  'See All',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                Icon(Icons.chevron_right, color: Color(0xFF2E7D32), size: 18),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard({
    required Map<String, dynamic> data,
    required VoidCallback onFavoriteTap,
    required VoidCallback onAddTap,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: data),
          ),
        );
      },
      child: Container(
        width: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: data['imageColor'],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child:
                        (data['imageUrl'] != null &&
                            data['imageUrl'].toString().isNotEmpty)
                        ? Image.network(
                            data['imageUrl'],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          )
                        : Center(
                            child: Icon(
                              Icons.image,
                              size: 40,
                              color: Colors.black.withOpacity(0.2),
                            ),
                          ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: onFavoriteTap,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        data['isFavorite']
                            ? Icons.favorite
                            : Icons.favorite_border,
                        size: 16,
                        color: data['isFavorite']
                            ? Colors.red
                            : const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 3,
                          backgroundColor: Color(0xFF2E7D32),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          data['stockBadge'],
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['category'],
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6B7280),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data['title'],
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          data['farmerName'],
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF4B5563),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.verified,
                        size: 12,
                        color: Color(0xFF2E7D32),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Price',
                              style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Rs. ${data['price']}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1F2937),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  data['unit'],
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: onAddTap,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFF2E7D32),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 18,
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
      ),
    );
  }

  Widget _buildFarmerCard({
    required Map<String, dynamic> data,
    required VoidCallback onFollowTap,
  }) {
    bool isFollowing = data['isFollowing'] ?? false;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => FarmerProfileScreen(farmer: data)),
        );
      },
      child: Container(
        width: 260,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 24,
                  backgroundColor: Color(0xFFE5E7EB),
                  child: Icon(Icons.person, color: Colors.grey),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              data['name'],
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F2937),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.verified,
                            size: 14,
                            color: Color(0xFF2E7D32),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 12,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${data['rating']} (${data['reviews'] ?? 0})',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 12,
                            color: Color(0xFF6B7280),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              data['location'],
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF6B7280),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        data['tags'] ?? 'Verified Farm',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onFollowTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isFollowing
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isFollowing ? 'Following' : 'Follow',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isFollowing
                            ? Colors.white
                            : const Color(0xFF1F2937),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RefinedBasketIcon extends StatelessWidget {
  final double size;
  final Color color;

  const _RefinedBasketIcon({
    this.size = 22,
    this.color = const Color(0xFF2E8B38),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RefinedBasketPainter(color: color),
      ),
    );
  }
}

class _RefinedBasketPainter extends CustomPainter {
  final Color color;
  _RefinedBasketPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.085
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    // Tapered basket body:
    final path = Path();
    path.moveTo(w * 0.16, h * 0.44);
    path.lineTo(w * 0.84, h * 0.44);
    path.lineTo(w * 0.76, h * 0.86);
    path.arcToPoint(
      Offset(w * 0.70, h * 0.90),
      radius: Radius.circular(w * 0.06),
      clockwise: true,
    );
    path.lineTo(w * 0.30, h * 0.90);
    path.arcToPoint(
      Offset(w * 0.24, h * 0.86),
      radius: Radius.circular(w * 0.06),
      clockwise: true,
    );
    path.close();
    canvas.drawPath(path, paint);

    // Left handle (angled slightly inwards)
    canvas.drawLine(
      Offset(w * 0.32, h * 0.44),
      Offset(w * 0.39, h * 0.18),
      paint,
    );

    // Right handle (angled slightly inwards)
    canvas.drawLine(
      Offset(w * 0.68, h * 0.44),
      Offset(w * 0.61, h * 0.18),
      paint,
    );

    // Center circular badge/hole
    final circlePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.075;
    canvas.drawCircle(Offset(w * 0.50, h * 0.65), w * 0.08, circlePaint);
  }

  @override
  bool shouldRepaint(covariant _RefinedBasketPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _CustomerHomeHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double topPadding;
  final Color primaryGreen;
  final Color darkText;
  final Color greyText;
  final String userName;
  final VoidCallback onCartTap;
  final VoidCallback onProfileTap;
  final VoidCallback onSearchTap;

  _CustomerHomeHeaderDelegate({
    required this.topPadding,
    required this.primaryGreen,
    required this.darkText,
    required this.greyText,
    required this.userName,
    required this.onCartTap,
    required this.onProfileTap,
    required this.onSearchTap,
  });

  double get _safeTop => topPadding > 0 ? topPadding : 12.0;

  @override
  double get minExtent => _safeTop + 56.0;

  @override
  double get maxExtent => _safeTop + 375.0;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Morning'
        : (hour < 17 ? 'Afternoon' : 'Evening');
    final displayName = userName.trim().isNotEmpty
        ? userName.trim().split(' ').first
        : 'Hannah';

    final maxShrink = maxExtent - minExtent;
    final progress = (shrinkOffset / maxShrink).clamp(0.0, 1.0);

    return ClipRect(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF43B251),
              Color(0xFF47B455),
              Color(0xFF8CD095),
              Color(0xFFD5EED8),
              Color(0xFFEEF8EF),
              Color(0xFFF9FBF9),
              Color(0xFFF9FBF9),
            ],
            stops: [0.00, 0.14, 0.21, 0.28, 0.38, 0.56, 1.00],
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                // HERO AREA: Slides under as lower content scrolls up over it
                Positioned(
                  top: minExtent - (shrinkOffset * 0.30),
                  left: 0,
                  right: 0,
                  height: maxExtent - minExtent,
                  child: Opacity(
                    opacity: (1.0 - progress * 1.3).clamp(0.0, 1.0),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // 1. Centered Hero Typography (sitting on soft mint-white backdrop, clear of the hat)
                        Positioned(
                          top: 16,
                          left: 20,
                          right: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.center,
                                child: RichText(
                                  textAlign: TextAlign.center,
                                  text: const TextSpan(
                                    style: TextStyle(
                                      fontSize: 18.5,
                                      fontWeight: FontWeight.w800,
                                      height: 1.2,
                                      letterSpacing: 0.6,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'FROM HARVEST ',
                                        style: TextStyle(
                                          color: Color(0xFF1A241B),
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'TO HANDOVER',
                                        style: TextStyle(
                                          color: Color(0xFF238A30),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5),
                              const FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.center,
                                child: Text(
                                  'HarvestHub brings the entire journey together',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xFF566659),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    height: 1.2,
                                    letterSpacing: 0.1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 2. Single Panoramic HarvestHub Hero Illustration (corner-free, full-width fit)
                        Positioned(
                          top: 66,
                          left: 4,
                          right: 4,
                          bottom: 58,
                          child: Image.asset(
                            'assets/images/harvesthub_hero_v2.png',
                            fit: BoxFit.contain,
                            alignment: Alignment.center,
                            filterQuality: FilterQuality.high,
                          ),
                        ),

                        // 3. Pill Search Bar
                        Positioned(
                          bottom: 6,
                          left: 16,
                          right: 16,
                          child: GestureDetector(
                            onTap: onSearchTap,
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(28),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x0A000000),
                                    blurRadius: 14,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 18),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.search_rounded,
                                    color: Color(0xFF8E9690),
                                    size: 22,
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Search vegetables, fruits and more',
                                      style: TextStyle(
                                        color: Color(0xFF8E9690),
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.tune_rounded,
                                    color: Color(0xFF8E9690),
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // PINNED STICKY TOP BAR: Stays fixed at the top always!
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: minExtent,
                  child: Container(
                    decoration: BoxDecoration(
                      color: progress > 0.05
                          ? Color.lerp(
                              const Color(0xFF43B251),
                              const Color(0xFF389E45),
                              progress,
                            )
                          : Colors.transparent,
                      boxShadow: progress > 0.75
                          ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.10),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    padding: EdgeInsets.only(
                      top: _safeTop,
                      left: 16,
                      right: 16,
                    ),
                    child: Row(
                      children: [
                        // Profile 3D Avatar (tapping navigates to Profile)
                        GestureDetector(
                          onTap: onProfileTap,
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F7EA),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFE8F7EA),
                                width: 1.5,
                              ),
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/customer_avatar.png',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: const Color(0xFFE8F7EA),
                                  child: Icon(Icons.person, color: primaryGreen, size: 22),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$greeting, $displayName',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.1,
                                  height: 1.15,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'What would you buy today?',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.95),
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w400,
                                  height: 1.15,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Sticky Cart Button with Refined Basket Icon & Live Badge
                        GestureDetector(
                          onTap: onCartTap,
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Stack(
                              clipBehavior: Clip.none,
                              alignment: Alignment.center,
                              children: [
                                const _RefinedBasketIcon(
                                  size: 21,
                                  color: Color(0xFF38A745),
                                ),
                                Consumer<CartProvider>(
                                  builder: (context, cart, child) {
                                    if (cart.itemCount == 0) return const SizedBox.shrink();
                                    return Positioned(
                                      top: 1,
                                      right: 1,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFEF4444),
                                          shape: BoxShape.circle,
                                        ),
                                        constraints: const BoxConstraints(
                                          minWidth: 16,
                                          minHeight: 16,
                                        ),
                                        child: Text(
                                          '${cart.itemCount}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
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
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _CustomerHomeHeaderDelegate oldDelegate) {
    return oldDelegate.userName != userName ||
        oldDelegate.topPadding != topPadding ||
        oldDelegate.primaryGreen != primaryGreen;
  }
}
