import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart' as app_auth;
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/product_model.dart';
import '../../providers/cart_provider.dart';
import '../../services/database_service.dart';
import '../../core/auth_interceptor.dart';
import 'product_detail_screen.dart';

class FarmerProfileScreen extends StatefulWidget {
  final Map<String, dynamic> farmer;

  const FarmerProfileScreen({Key? key, required this.farmer}) : super(key: key);

  @override
  State<FarmerProfileScreen> createState() => _FarmerProfileScreenState();
}

class _FarmerProfileScreenState extends State<FarmerProfileScreen> {
  String _selectedCategory = 'All Harvest (14)';
  final DatabaseService _dbService = DatabaseService();

  @override
  void initState() {
    super.initState();
    
  }

  void _toggleFollow() async {
    AuthInterceptor.executeAction(context, () async {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      
      

      try {
        await _dbService.toggleFollowFarmer(uid, widget.farmer['id'] ?? '');
      } catch (e) {
        if (mounted) {
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update follow status')),
          );
        }
      }
    });
  }

  void _toggleFavorite(List<Map<String, dynamic>> list, int index) {
    setState(() {
      list[index]['isFavorite'] = !(list[index]['isFavorite'] as bool);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProv = Provider.of<app_auth.AuthProvider>(context);
    final isFollowing = (authProv.currentCustomer?.followedFarmers ?? []).contains(widget.farmer['id']?.toString());

    const Color primaryGreen = Color(0xFF1B5E20);
    const Color buttonGreen = Color(0xFF007E33);
    const Color darkText = Color(0xFF1F2937);
    const Color greyText = Color(0xFF6B7280);
    const Color background = Color(0xFFF9FBF9);

    final farmerName = widget.farmer['name'] ?? 'Green Valley Farm';

    
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: darkText),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Farm Profile',
          style: TextStyle(
            color: darkText,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.shopping_bag_outlined, color: darkText),
                Consumer<CartProvider>(
                  builder: (context, cart, child) {
                    if (cart.itemCount == 0) return const SizedBox.shrink();
                    return Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: buttonGreen,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${cart.itemCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: buttonGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 16),
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 240,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 180,
                    child: Container(
                      color: const Color(0xFFE5E7EB),
                      child: Image.network(
                        (widget.farmer['imageUrl'] != null && widget.farmer['imageUrl'].toString().isNotEmpty)
                            ? widget.farmer['imageUrl']
                            : 'https://placehold.co/800x400/2E7D32/FFFFFF/png?text=Farm+Profile',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(
                              child: Icon(
                                Icons.image,
                                size: 48,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                      ),
                    ),
                  ),
                  const SizedBox.shrink(),
                  Positioned(
                    top: 120,
                    left: 16,
                    child: Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            color: const Color(0xFFE5E7EB),
                          ),
                          child: ClipOval(
                            child: Image.network(
                              (widget.farmer['imageUrl'] != null && widget.farmer['imageUrl'].toString().isNotEmpty)
                                  ? widget.farmer['imageUrl']
                                  : 'https://placehold.co/200x200/2E7D32/FFFFFF/png?text=F',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                    Icons.person,
                                    size: 48,
                                    color: Color(0xFF9CA3AF),
                                  ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: buttonGreen,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 190,
                    right: 16,
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: _toggleFollow,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isFollowing ? buttonGreen : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isFollowing
                                    ? buttonGreen
                                    : Colors.grey[300]!,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isFollowing ? Icons.check : Icons.add,
                                  size: 16,
                                  color: isFollowing ? Colors.white : darkText,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isFollowing ? 'Following' : 'Follow',
                                  style: TextStyle(
                                    color: isFollowing
                                        ? Colors.white
                                        : darkText,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    farmerName,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: darkText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.greenAccent.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle, color: buttonGreen, size: 8),
                        SizedBox(width: 4),
                        Text(
                          widget.farmer['name'] ?? 'Fresh Produce',
                          style: TextStyle(
                            color: buttonGreen,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.farmer['contactNumber'] != null ? 'Contact: ' + widget.farmer['contactNumber'] : 'Verified Local Farmer',
                    style: const TextStyle(fontSize: 14, color: darkText),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star_border,
                              color: buttonGreen,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.farmer['rating'] ?? '4.8'}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: darkText,
                              ),
                            ),
                            Text(
                              ' (${widget.farmer['reviews'] ?? '120 reviews'})',
                              style: const TextStyle(
                                color: greyText,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: const [
                            Icon(
                              Icons.access_time,
                              color: buttonGreen,
                              size: 14,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Verified HarvestHub Partner',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: darkText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.storefront,
                        color: buttonGreen,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                            '${widget.farmer['location'] ?? 'Pakistan'}',
                          style: const TextStyle(color: darkText, fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
            const SizedBox.shrink(),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'About Our Farm',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: darkText,
                        ),
                      ),
                      Icon(Icons.eco_outlined, color: darkText),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                      (widget.farmer['specialty'] != null && widget.farmer['specialty'] != 'Fresh Local Produce')
                          ? widget.farmer['specialty']
                          : 'This is a verified local farm partnering with HarvestHub to bring you fresh, quality produce directly from the fields.',
                      style: const TextStyle(
                        color: Color(0xFF4B5563),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Farm Catalog',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: darkText,
                    ),
                  ),
                  Text(
                    'Farm Products',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: buttonGreen,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 36,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 0,
                itemBuilder: (context, index) {
                  final cat = '';
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = cat;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected ? buttonGreen : Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          cat,
                          style: TextStyle(
                            color: isSelected ? Colors.white : darkText,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            StreamBuilder<List<ProductModel>>(
              stream: _dbService.streamProductsByFarmer(widget.farmer['id'] ?? ''),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: primaryGreen));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(
                      child: Text(
                        "No products available.",
                        style: TextStyle(color: greyText, fontSize: 16),
                      ),
                    ),
                  );
                }

                final products = snapshot.data!.map((p) => {
                  'productModel': p,
                  'id': p.id,
                  'title': p.name,
                  'category': p.categoryName.isNotEmpty ? p.categoryName.toUpperCase() : 'PRODUCE',
                  'farmerName': p.farmerName ?? widget.farmer['name'] ?? 'Farm',
                  'price': p.price.toStringAsFixed(0),
                  'unit': '/ ${p.unit}',
                  'stockBadge': '${p.quantity.toInt()} ${p.unit} available',
                  'isFavorite': false,
                  'imageColor': const Color(0xFFA5D6A7),
                  'imageUrl': p.imageUrl ?? '',
                  'description': p.description,
                }).toList();

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      return _buildProductCard(
                        data: products[index],
                        onFavoriteTap: () => _toggleFavorite(products, index),
                        onAddTap: () {},
                        context: context,
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutChip(IconData icon, String label, Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
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
    required BuildContext context,
  }) {
    const Color buttonGreen = Color(0xFF007E33);
    const Color darkText = Color(0xFF1F2937);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProductDetailScreen(product: data)),
        );
      },
      child: Container(
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
            Expanded(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: data['imageColor'] ?? Colors.grey[200],
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    width: double.infinity,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
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
                          data['isFavorite'] == true
                              ? Icons.favorite
                              : Icons.favorite_border,
                          size: 16,
                          color: data['isFavorite'] == true
                              ? Colors.red
                              : Colors.grey,
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
                      child: Text(
                        'Picked Today',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: buttonGreen,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['title'] ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: darkText,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    data['subtitle'] ?? '12 kg ready for pickup',
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            data['price'] ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: darkText,
                              fontSize: 14,
                            ),
                          ),
                          const Text(
                            ' /kg',
                            style: TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: onAddTap,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: buttonGreen,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 16,
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
}
