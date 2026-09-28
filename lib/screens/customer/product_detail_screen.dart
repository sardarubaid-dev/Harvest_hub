import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/auth_interceptor.dart';
import '../../services/database_service.dart';
import 'farmer_profile_screen.dart';
import '../../models/product_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/wishlist_provider.dart';
import 'package:provider/provider.dart';
import '../../models/review_model.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic>? product;

  const ProductDetailScreen({Key? key, this.product}) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  late int _pricePerUnit;
  

  @override
  void initState() {
    super.initState();
    
    final p = widget.product;
    _pricePerUnit = widget.product != null
        ? int.tryParse(widget.product?['price']?.toString() ?? '280') ?? 280
        : 280;
    
  }

  void _increment() {
    setState(() => _quantity++);
  }

  void _decrement() {
    if (_quantity > 1) setState(() => _quantity--);
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    const Color primaryGreen = Color(0xFF2E7D32);
    const Color darkText = Color(0xFF1F2937);
    const Color greyText = Color(0xFF6B7280);
    const Color background = Color(0xFFF9FBF9);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            
            Container(
              color: background,
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: darkText),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: primaryGreen,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.eco,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'HarvestHub',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: darkText,
                              height: 1.0,
                            ),
                          ),
                          const Text(
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
                  const Text(
                    'Product...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: darkText,
                    ),
                  ),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: primaryGreen,
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
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    Stack(
                      children: [
                        Container(
                          height: 300,
                          width: double.infinity,
                          color: widget.product?['imageColor'] ?? const Color(0xFFA5D6A7),
                          child: Builder(
                            builder: (context) {
                              final imageUrl = widget.product?['imageUrl'] ??
                                  widget.product?['Image_Url'];
                              if (imageUrl != null &&
                                  imageUrl.toString().trim().isNotEmpty) {
                                return Image.network(
                                  imageUrl.toString().trim(),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: 300,
                                  errorBuilder: (_, __, ___) =>
                                      _buildImagePlaceholder(),
                                );
                              }
                              return _buildImagePlaceholder();
                            },
                          ),
                        ),
                        Positioned(
                          top: 16,
                          right: 16,
                          child: GestureDetector(
                            onTap: () => AuthInterceptor.executeAction(
                                context,
                                () {
                                  final id = p != null ? p['id']?.toString() : null;
                                  if (id != null) {
                                    Provider.of<WishlistProvider>(context, listen: false).toggleWishlist(id);
                                  }
                                },
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Consumer<WishlistProvider>(
                                  builder: (context, wishlistProvider, _) {
                                    final id = p != null ? p['id']?.toString() : null;
                                    final isFav = id != null && wishlistProvider.isFavorite(id);
                                    return Icon(
                                      isFav ? Icons.favorite : Icons.favorite_border,
                                      color: isFav ? Colors.red : darkText,
                                      size: 20,
                                    );
                                  },
                                ),
                              ),
                          ),
                        ),
                        Positioned(
                          bottom: 16,
                          left: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: const [
                                Icon(
                                  Icons.photo_library_outlined,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  '1 / 4',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: primaryGreen,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[400],
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[400],
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[400],
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    const CircleAvatar(
                                      radius: 3,
                                      backgroundColor: primaryGreen,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      widget.product?['stockBadge'] ??
                                          'In Stock • Available',
                                      style: const TextStyle(
                                        color: primaryGreen,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: const [
                                  Icon(
                                    Icons.verified_outlined,
                                    color: primaryGreen,
                                    size: 14,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Verified Harvest',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: darkText,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          Text(
                            widget.product?['title'] ?? 'Fresh Tomatoes',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: darkText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Rs. $_pricePerUnit',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: primaryGreen,
                                ),
                              ),
                              Text(
                                widget.product?['unit'] ?? ' / kg',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: greyText,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          Row(
                            children: [
                              const Icon(
                                Icons.star_border,
                                color: Colors.orange,
                                size: 16,
                              ),
                              const Icon(
                                Icons.star_border,
                                color: Colors.orange,
                                size: 16,
                              ),
                              const Icon(
                                Icons.star_border,
                                color: Colors.orange,
                                size: 16,
                              ),
                              const Icon(
                                Icons.star_border,
                                color: Colors.orange,
                                size: 16,
                              ),
                              const Icon(
                                Icons.star_half,
                                color: Colors.orange,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                '4.8',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: darkText,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                '(84 reviews)',
                                style: TextStyle(fontSize: 13, color: greyText),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 4,
                                height: 4,
                                decoration: const BoxDecoration(
                                  color: greyText,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              '98% Verified Buyers',
                              style: TextStyle(
                                color: primaryGreen,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFE5E7EB),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.access_time,
                                    size: 16,
                                    color: primaryGreen,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      'Harvest Timeline',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: greyText,
                                      ),
                                    ),
                                    Text(
                                      'Harvested yesterday morning',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: darkText,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: const [
                                    Icon(
                                      Icons.eco_outlined,
                                      color: primaryGreen,
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'About This Product',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: darkText,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  widget.product?['description'] ??
                                      'Locally grown pesticide-free produce ripened under natural sunlight. Crisp texture with rich balanced sweetness and acidity, perfect for fresh cooking.',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: greyText,
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _buildChip(
                                      Icons.eco_outlined,
                                      'Pesticide-Free',
                                    ),
                                    _buildChip(
                                      Icons.park_outlined,
                                      '100% Organic Soil',
                                    ),
                                    _buildChip(
                                      Icons.verified_outlined,
                                      'Non-GMO',
                                    ),
                                    _buildChip(
                                      Icons.pan_tool_outlined,
                                      'Hand-Picked',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'GROWN WITH CARE BY',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: greyText,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE5E7EB),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        children: const [
                                          Icon(
                                            Icons.verified_outlined,
                                            size: 12,
                                            color: primaryGreen,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            'Certified Grower',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: darkText,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    const CircleAvatar(
                                      radius: 24,
                                      backgroundColor: Color(0xFFE5E7EB),
                                      child: Icon(
                                        Icons.person,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            widget.product?['farmerName'] ??
                                                'Green Valley Farm',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: darkText,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          const Text(
                                            'Tariq Mehmood (Farmer since 2012)',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: greyText,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: const [
                                              Icon(
                                                Icons.star_border,
                                                size: 12,
                                                color: Colors.orange,
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                '4.8',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: darkText,
                                                ),
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                '• 120 orders completed',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: greyText,
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
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3F4F6),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.location_on_outlined,
                                        size: 16,
                                        color: primaryGreen,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: RichText(
                                          text: const TextSpan(
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: darkText,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: 'Karachi Farmers Market (Stall 14B) ',
                                              ),
                                              TextSpan(
                                                text: '• 2.4 km away',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  height: 40,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      final farmerName =
                                          widget.product?['farmerName'] ?? '';
                                      final farmerData = <String, dynamic>{
                                        'id': 'f0',
                                        'name': farmerName,
                                        'rating': '5.0',
                                        'reviews': '120 reviews',
                                        'location': 'Local Farm',
                                        'isFollowing': false,
                                      };
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => FarmerProfileScreen(
                                            farmer: farmerData,
                                          ),
                                        ),
                                      ).then((_) => setState(() {}));
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFE5E7EB),
                                      foregroundColor: primaryGreen,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        Text(
                                          'View Farm Profile',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Icon(Icons.arrow_forward, size: 16),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFE8F5E9),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.storefront,
                                    color: primaryGreen,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Pickup Information',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: darkText,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      RichText(
                                        text: const TextSpan(
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: greyText,
                                            height: 1.4,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: 'Available for pickup ',
                                            ),
                                            TextSpan(
                                              text: 'Today from 10:00 AM - 6:00 PM',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: darkText,
                                              ),
                                            ),
                                            TextSpan(
                                              text: ' at Karachi Farmers Market Hub.',
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),
                          _buildReviewsSection(),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  
                  Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, size: 20),
                          onPressed: _decrement,
                        ),
                        SizedBox(
                          width: 40,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$_quantity',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: darkText,
                                  height: 1.0,
                                ),
                              ),
                              Text(
                                widget.product?['unit']
                                        ?.replaceAll('/', '')
                                        ?.trim() ??
                                    'kg',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: greyText,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, size: 20),
                          onPressed: _increment,
                        ),
                      ],
                    ),
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Total Price',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: greyText,
                        ),
                      ),
                      Text(
                        'Rs. ${_pricePerUnit * _quantity}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: primaryGreen,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    AuthInterceptor.executeAction(context, () async {
                      if (widget.product != null) {
                        await DatabaseService().addToCart(
                          uid: FirebaseAuth.instance.currentUser?.uid,
                          product: widget.product!,
                          quantityDelta: _quantity,
                        );
                      }
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Added $_quantity ${widget.product?['title'] ?? 'item'} to Cart!',
                          ),
                        ),
                      );
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.shopping_basket_outlined, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Add to Cart',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF2E7D32)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    final title = (widget.product?['title'] ?? widget.product?['name'] ?? '').toString();
    final cat = (widget.product?['category'] ?? '').toString().toLowerCase();

    String fallbackUrl =
        'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?q=80&w=600&auto=format&fit=crop';
    if (cat.contains('dairy') ||
        title.toLowerCase().contains('milk') ||
        title.toLowerCase().contains('ghee')) {
      fallbackUrl =
          'https://images.unsplash.com/photo-1563636619-e9143da7973b?q=80&w=600&auto=format&fit=crop';
    } else if (cat.contains('fruit') ||
        title.toLowerCase().contains('apple')) {
      fallbackUrl =
          'https://images.unsplash.com/photo-1568702846914-96b305d2aaeb?q=80&w=600&auto=format&fit=crop';
    } else if (cat.contains('honey') ||
        title.toLowerCase().contains('honey')) {
      fallbackUrl =
          'https://images.unsplash.com/photo-1628151015968-3a4429e9ef04?q=80&w=600&auto=format&fit=crop';
    } else if (cat.contains('spinach') ||
        title.toLowerCase().contains('spinach') ||
        cat.contains('herb')) {
      fallbackUrl =
          'https://images.unsplash.com/photo-1576045057995-568f588f82fb?q=80&w=600&auto=format&fit=crop';
    } else if (title.toLowerCase().contains('carrot')) {
      fallbackUrl =
          'https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?q=80&w=600&auto=format&fit=crop';
    } else if (cat.contains('egg') || title.toLowerCase().contains('egg')) {
      fallbackUrl =
          'https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?q=80&w=600&auto=format&fit=crop';
    }

    return Image.network(
      fallbackUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: 300,
      errorBuilder: (_, __, ___) => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFA5D6A7),
              Color(0xFF2E7D32),
            ],
          ),
        ),
        child: const Center(
          child: Icon(Icons.eco, size: 80, color: Colors.white70),
        ),
      ),
    );
  }
  Widget _buildReviewsSection() {
    final productId = widget.product?['id'] ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Customer Reviews',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
            ),
            TextButton(
              onPressed: () => _showReviewDialog(productId),
              child: const Text('Write a Review', style: TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        StreamBuilder<List<ReviewModel>>(
          stream: DatabaseService().streamProductReviews(productId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final reviews = snapshot.data ?? [];
            if (reviews.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: const Color(0xFFF9FBF9), borderRadius: BorderRadius.circular(12)),
                child: const Text('No reviews yet. Be the first to review this product!', style: TextStyle(color: Color(0xFF6B7280)), textAlign: TextAlign.center),
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                final rev = reviews[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E7EB))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(radius: 16, backgroundColor: const Color(0xFFA5D6A7), child: Text(rev.customerName.isNotEmpty ? rev.customerName[0].toUpperCase() : 'C', style: const TextStyle(fontSize: 12, color: Colors.white))),
                              const SizedBox(width: 8),
                              Text(rev.customerName.isNotEmpty ? rev.customerName : 'Verified Customer', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            ],
                          ),
                          Row(
                            children: List.generate(5, (starIdx) => Icon(starIdx < rev.rating ? Icons.star : Icons.star_border, color: Colors.orange, size: 14)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(rev.comment, style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563))),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  void _showReviewDialog(String productId) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You must be logged in to add a review.')));
      return;
    }
    int selectedRating = 5;
    final commentController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateSB) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Write a Review'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(index < selectedRating ? Icons.star : Icons.star_border, color: Colors.orange, size: 32),
                        onPressed: () => setStateSB(() => selectedRating = index + 1),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: commentController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Share your experience with this product...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
                ElevatedButton(
                  onPressed: () async {
                    if (commentController.text.trim().isEmpty) return;
                    final user = FirebaseAuth.instance.currentUser;
                    final newReview = ReviewModel(
                      id: '',
                      customerId: user?.uid ?? 'guest',
                      customerName: user?.displayName ?? 'Verified Customer',
                      targetType: 'product',
                      targetId: productId,
                      rating: selectedRating.toDouble(),
                      comment: commentController.text.trim(),
                      createdAt: DateTime.now(),
                    );
                    await DatabaseService().addReview(newReview);
                    if (mounted) Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  child: const Text('Submit'),
                ),
              ],
            );
          }
        );
      },
    );
  }
}