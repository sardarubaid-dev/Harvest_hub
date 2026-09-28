with open('lib/screens/customer/customer_home_screen.dart', 'r', encoding='utf-8') as f:
    c = f.read()

import re

pattern = re.compile(r'Positioned\(\s*top:\s*8,\s*right:\s*8,\s*child:\s*GestureDetector\(\s*onTap:\s*onFavoriteTap,\s*child:\s*Container\(\s*padding:\s*const\s*EdgeInsets\.all\(6\),\s*decoration:\s*const\s*BoxDecoration\(\s*color:\s*Colors\.white,\s*shape:\s*BoxShape\.circle,\s*\),\s*child:\s*Icon\(\s*data\[\'isFavorite\'\]\s*\?\s*Icons\.favorite\s*:\s*Icons\.favorite_border,\s*size:\s*16,\s*color:\s*data\[\'isFavorite\'\]\s*\?\s*Colors\.red\s*:\s*const\s*Color\(0xFF6B7280\),\s*\),\s*\),\s*\),\s*\),')

new_fav_btn = '''Positioned(
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

c, count = pattern.subn(new_fav_btn, c)
print(f"Replaced {count} instances.")

with open('lib/screens/customer/customer_home_screen.dart', 'w', encoding='utf-8') as f:
    f.write(c)

