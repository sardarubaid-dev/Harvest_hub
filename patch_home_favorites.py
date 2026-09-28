with open('lib/screens/customer/customer_home_screen.dart', 'r', encoding='utf-8') as f:
    c = f.read()

# Replace _toggleFavorite
old_toggle = '''  void _toggleFavorite(List<Map<String, dynamic>> list, int index) {
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
    });
  }'''
new_toggle = '''  void _toggleFavorite(List<Map<String, dynamic>> list, int index) {
    // Deprecated. Handled by WishlistProvider directly in the UI.
  }'''
c = c.replace(old_toggle, new_toggle)

# Update _buildProductCard signature and onTap
old_card = '''  Widget _buildProductCard({
    required Map<String, dynamic> data,
    required VoidCallback onFavoriteTap,
    required VoidCallback onAddTap,
  }) {
    return GestureDetector('''
new_card = '''  Widget _buildProductCard({
    required Map<String, dynamic> data,
    required VoidCallback onFavoriteTap,
    required VoidCallback onAddTap,
  }) {
    return GestureDetector('''
c = c.replace(old_card, new_card)

# Inside _buildProductCard, replace the Favorite button
old_fav_btn = '''                  Positioned(
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
                  ),'''
new_fav_btn = '''                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        AuthInterceptor.executeAction(context, () {
                          final id = data['id']?.toString();
                          if (id != null) {
                            Provider.of<WishlistProvider>(context, listen: false).toggleWishlist(id);
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Consumer<WishlistProvider>(
                          builder: (context, wishlistProvider, _) {
                            final id = data['id']?.toString();
                            final isFav = id != null && wishlistProvider.isFavorite(id);
                            return Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              size: 16,
                              color: isFav ? Colors.red : const Color(0xFF6B7280),
                            );
                          },
                        ),
                      ),
                    ),
                  ),'''
c = c.replace(old_fav_btn, new_fav_btn)

# Make sure WishlistProvider is imported
if 'wishlist_provider.dart' not in c:
    c = c.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport '../../providers/wishlist_provider.dart';")

with open('lib/screens/customer/customer_home_screen.dart', 'w', encoding='utf-8') as f:
    f.write(c)

print("Done with customer_home_screen")
