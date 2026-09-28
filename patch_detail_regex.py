import re

with open('lib/screens/customer/product_detail_screen.dart', 'r', encoding='utf-8') as f:
    c = f.read()

pattern = re.compile(r'onTap:\s*\(\)\s*=>\s*AuthInterceptor\.executeAction\(\s*context,\s*\(\)\s*=>\s*setState\(\(\)\s*=>\s*_isFavorite\s*=\s*!_isFavorite\),\s*\),\s*child:\s*Container\(\s*padding:\s*const\s*EdgeInsets\.all\(8\),\s*decoration:\s*const\s*BoxDecoration\(\s*color:\s*Colors\.white,\s*shape:\s*BoxShape\.circle,\s*\),\s*child:\s*Icon\(\s*_isFavorite\s*\?\s*Icons\.favorite\s*:\s*Icons\.favorite_border,\s*color:\s*_isFavorite\s*\?\s*Colors\.red\s*:\s*darkText,\s*size:\s*20,\s*\),\s*\),')

new_btn = '''onTap: () => AuthInterceptor.executeAction(
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
                              ),'''

c, count = pattern.subn(new_btn, c)
print(f"Replaced {count} instances.")

with open('lib/screens/customer/product_detail_screen.dart', 'w', encoding='utf-8') as f:
    f.write(c)
