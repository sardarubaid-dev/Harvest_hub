with open('lib/screens/customer/products_screen.dart', 'r', encoding='utf-8') as f:
    c = f.read()

old_fav_btn = '''                                      child: GestureDetector(
                                        onTap: () {
                                          AuthInterceptor.executeAction(context, () {
                                            
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            data['isFavorite'] == true ? Icons.favorite : Icons.favorite_border,
                                            size: 16,
                                            color: data['isFavorite'] == true ? Colors.red : const Color(0xFF6B7280),
                                          ),
                                        ),
                                      ),'''

new_fav_btn = '''                                      child: GestureDetector(
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
                                      ),'''

c = c.replace(old_fav_btn, new_fav_btn)

if 'wishlist_provider.dart' not in c:
    c = c.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport '../../providers/wishlist_provider.dart';")

with open('lib/screens/customer/products_screen.dart', 'w', encoding='utf-8') as f:
    f.write(c)

print("Done with products_screen")
