import 'package:flutter/material.dart';

import '../../widgets/harvi_avatar.dart';
import 'chatbot_screen.dart';

import 'package:provider/provider.dart';

import '../../core/dummy_data.dart';
import '../../core/auth_interceptor.dart';
import '../../providers/auth_provider.dart';
import 'product_detail_screen.dart';
import 'categories_screen.dart';
import 'products_screen.dart';
import 'wishlist_screen.dart';
import 'orders_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';
import 'farmer_profile_screen.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({Key? key}) : super(key: key);

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  int _currentIndex = 0;
  String _selectedCategoryId = '1';
  String _selectedGlobalCategory = 'All';

  // Local state to simulate database interactions
  late List<Map<String, dynamic>> _freshProducts;
  late List<Map<String, dynamic>> _popularFarmers;
  late List<Map<String, dynamic>> _recentlyRestocked;

  @override
  void initState() {
    super.initState();
    // Load from "JSON"
    _freshProducts = List<Map<String, dynamic>>.from(
      DummyData.freshProducts.map((e) => Map<String, dynamic>.from(e)),
    );
    _popularFarmers = List<Map<String, dynamic>>.from(
      DummyData.popularFarmers.map((e) => Map<String, dynamic>.from(e)),
    );
    _recentlyRestocked = List<Map<String, dynamic>>.from(
      DummyData.recentlyRestocked.map((e) => Map<String, dynamic>.from(e)),
    );
  }

  void _toggleFavorite(List<Map<String, dynamic>> list, int index) {
    AuthInterceptor.executeAction(context, () {
      setState(() {
        list[index]['isFavorite'] = !(list[index]['isFavorite'] as bool);
      });
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            list[index]['isFavorite']
                ? 'Added to Wishlist'
                : 'Removed from Wishlist',
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    });
  }

  void _addToCart(Map<String, dynamic> product) {
    AuthInterceptor.executeAction(context, () {
      setState(() {
        int index = DummyData.cart.indexWhere((p) => p['id'] == product['id']);
        if (index != -1) {
          DummyData.cart[index]['quantity'] =
              (DummyData.cart[index]['quantity'] as int) + 1;
        } else {
          Map<String, dynamic> cartItem = Map.from(product);
          cartItem['quantity'] = 1;
          DummyData.cart.add(cartItem);
        }
      });
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Added \ to Cart!')));
    });
  }

  void _toggleFollow(int index) {
    setState(() {
      _popularFarmers[index]['isFollowing'] =
          !(_popularFarmers[index]['isFollowing'] as bool);
    });
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _popularFarmers[index]['isFollowing']
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
        child: Column(
          children: [
            if (_currentIndex != 5)
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
                        _currentIndex = 1; // Switch to Products tab
                      });
                    },
                  ),
                  const WishlistScreen(),
                  OrdersScreen(
                    onShopNow: () {
                      setState(() {
                        _selectedGlobalCategory = 'All';
                        _currentIndex = 1; // Switch to Products tab
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
          Column(
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
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.search, color: darkText, size: 24),
                onPressed: () {
                  setState(() {
                    _currentIndex = 1; // Switch to Products tab
                  });
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
                    if (DummyData.cart.isNotEmpty)
                      Positioned(
                        top: -4,
                        right: -4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: primaryGreen,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${DummyData.cart.length}',
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
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () => setState(() => _currentIndex = 5), // Profile
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
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: TextField(
                      readOnly: true,
                      onTap: () => setState(() => _currentIndex = 1),
                      decoration: InputDecoration(
                        hintText: 'Search fresh groceries...',
                        hintStyle: TextStyle(color: greyText, fontSize: 14),
                        prefixIcon: Icon(Icons.search, color: greyText),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: primaryGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.tune, color: Colors.white),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10), // Categories from JSON
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: DummyData.categories.length,
              itemBuilder: (context, index) {
                final cat = DummyData.categories[index];
                final isSelected = _selectedCategoryId == cat['id'];
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _selectedCategoryId = cat['id']);
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
                            cat['icon'],
                            size: 16,
                            color: isSelected ? Colors.white : primaryGreen,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            cat['name'],
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

          // Fresh Near You
          _buildSectionHeader('Fresh Near You', 'Today'),
          const SizedBox(height: 16),
          SizedBox(
            height: 260,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _freshProducts
                  .where(
                    (p) =>
                        _selectedCategoryId == '1' ||
                        p['category'].toString().toLowerCase() ==
                            DummyData.categories
                                .firstWhere(
                                  (c) => c['id'] == _selectedCategoryId,
                                )['name']
                                .toString()
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
                              DummyData.categories
                                  .firstWhere(
                                    (c) => c['id'] == _selectedCategoryId,
                                  )['name']
                                  .toString()
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

          // Recently Restocked
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

          const SizedBox(height: 24),

          // Bottom Banner
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
                      Column(
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
                              Text(
                                'Rs. ${data['price']}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1F2937),
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
                            '${data['rating']} (${data['reviews']})',
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
                        data['tags'],
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
