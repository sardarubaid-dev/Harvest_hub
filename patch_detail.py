with open('lib/screens/customer/product_detail_screen.dart', 'r', encoding='utf-8') as f:
    c = f.read()

c = c.replace("import '../../providers/cart_provider.dart';", "import '../../providers/cart_provider.dart';\nimport '../../providers/wishlist_provider.dart';")
c = c.replace("bool _isFavorite = false;", "")
c = c.replace("_isFavorite = p != null ? (p['isFavorite'] ?? false) : false;", "")

old_btn = '''                              onTap: () => AuthInterceptor.executeAction(
                                context,
                                () => setState(() => _isFavorite = !_isFavorite),
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: _isFavorite ? Colors.red : darkText,
                                  size: 20,
                                ),'''

new_btn = '''                              onTap: () => AuthInterceptor.executeAction(
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
                                ),'''

c = c.replace(old_btn, new_btn)

with open('lib/screens/customer/product_detail_screen.dart', 'w', encoding='utf-8') as f:
    f.write(c)
print('Done')
