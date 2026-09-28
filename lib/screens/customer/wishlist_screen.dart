import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/auth_interceptor.dart';
import '../../providers/auth_provider.dart' as app_auth;
import '../../models/product_model.dart';
import '../../services/database_service.dart';
import '../../providers/wishlist_provider.dart';
import 'product_detail_screen.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({Key? key}) : super(key: key);

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final DatabaseService _dbService = DatabaseService();

  String? get _currentUid {
    final fbUid = FirebaseAuth.instance.currentUser?.uid;
    if (fbUid != null && fbUid.isNotEmpty) return fbUid;
    try {
      final authProv = Provider.of<app_auth.AuthProvider>(context, listen: false);
      return authProv.currentUser?.uid;
    } catch (_) {
      return null;
    }
  }

  void _toggleFavorite(String productId) {
    Provider.of<WishlistProvider>(context, listen: false).toggleWishlist(productId);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Wishlist Updated'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF2E7D32);
    const Color darkText = Color(0xFF1F2937);
    const Color greyText = Color(0xFF6B7280);
    const Color background = Color(0xFFF9FBF9);

    final uid = _currentUid;
    if (uid == null) {
      return Scaffold(
        backgroundColor: background,
        body: Center(child: Text('Please login to view wishlist')),
      );
    }

    return Scaffold(
      backgroundColor: background,
      body: Consumer<WishlistProvider>(
        builder: (context, wishlistProvider, _) {
          final wishlistIds = wishlistProvider.wishlistIds;

          if (wishlistIds.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No items in your wishlist',
                    style: TextStyle(fontSize: 16, color: greyText),
                  ),
                ],
              ),
            );
          }

          return StreamBuilder<List<ProductModel>>(
            stream: _dbService.streamAllProducts(),
            builder: (context, prodSnapshot) {
              if (!prodSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final allProducts = prodSnapshot.data!;
              final favoriteProducts = allProducts.where((p) => wishlistIds.contains(p.id)).toList();

              if (favoriteProducts.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite_border,
                        size: 64,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No items in your wishlist',
                        style: TextStyle(fontSize: 16, color: greyText),
                      ),
                    ],
                  ),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(16.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.65,
                ),
                itemCount: favoriteProducts.length,
                itemBuilder: (context, index) {
                  final p = favoriteProducts[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailScreen(product: {
                            'model': p,
                            'id': p.id,
                            'title': p.name,
                            'category': p.categoryName,
                            'farmerName': p.farmerName ?? '',
                            'price': p.price.toStringAsFixed(0),
                            'unit': p.unit,
                            'imageUrl': p.imageUrl ?? '',
                            'description': p.description,
                          }),
                        ),
                      );
                    },
                    child: Align(
                      alignment: Alignment.topCenter,
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
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                Container(
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: Colors.green[100],
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
                                    child: (p.imageUrl != null && p.imageUrl!.isNotEmpty)
                                        ? Image.network(
                                            p.imageUrl!,
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
                                    onTap: () => _toggleFavorite(p.id),
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.favorite,
                                        size: 16,
                                        color: Colors.red,
                                      ),
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
                                    p.categoryName,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF6B7280),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    p.name,
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
                                          p.farmerName ?? '',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF4B5563),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
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
                                                'Rs.  ',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF1F2937),
                                                ),
                                              ),
                                              Text(
                                                '/',
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  color: Color(0xFF6B7280),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
