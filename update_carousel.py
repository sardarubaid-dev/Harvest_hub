import re

with open('lib/screens/customer/product_detail_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Add _currentImageIndex
if 'int _currentImageIndex = 0;' not in content:
    content = content.replace(
        'class _ProductDetailScreenState extends State<ProductDetailScreen> {',
        'class _ProductDetailScreenState extends State<ProductDetailScreen> {\n  int _currentImageIndex = 0;'
    )

# The new Stack code
new_stack = """Stack(
                      children: [
                        Container(
                          height: 300,
                          width: double.infinity,
                          color: widget.product?['imageColor'] ?? const Color(0xFFA5D6A7),
                          child: Builder(
                            builder: (context) {
                              final p = widget.product;
                              List<String> images = [];
                              
                              if (p != null) {
                                if (p['imageUrls'] != null && p['imageUrls'] is List) {
                                  images = List<String>.from(p['imageUrls']);
                                } else {
                                  final singleImage = p['imageUrl'] ?? p['Image_Url'];
                                  if (singleImage != null && singleImage.toString().trim().isNotEmpty) {
                                    images = [singleImage.toString().trim()];
                                  }
                                }
                              }

                              if (images.isEmpty) {
                                return _buildImagePlaceholder();
                              }

                              if (images.length == 1) {
                                return Image.network(
                                  images.first,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: 300,
                                  errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                                );
                              }

                              return PageView.builder(
                                itemCount: images.length,
                                onPageChanged: (index) {
                                  setState(() {
                                    _currentImageIndex = index;
                                  });
                                },
                                itemBuilder: (context, index) {
                                  return Image.network(
                                    images[index],
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: 300,
                                    errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                                  );
                                },
                              );
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
                        // Only show indicators if there are multiple images
                        Builder(
                          builder: (context) {
                            final p = widget.product;
                            List<String> images = [];
                            if (p != null) {
                              if (p['imageUrls'] != null && p['imageUrls'] is List) {
                                images = List<String>.from(p['imageUrls']);
                              } else {
                                final singleImage = p['imageUrl'] ?? p['Image_Url'];
                                if (singleImage != null && singleImage.toString().trim().isNotEmpty) {
                                  images = [singleImage.toString().trim()];
                                }
                              }
                            }

                            if (images.length <= 1) return const SizedBox.shrink();

                            return Positioned(
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
                                  children: [
                                    const Icon(
                                      Icons.photo_library_outlined,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${_currentImageIndex + 1} / ${images.length}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                        ),
                        Builder(
                          builder: (context) {
                            final p = widget.product;
                            List<String> images = [];
                            if (p != null) {
                              if (p['imageUrls'] != null && p['imageUrls'] is List) {
                                images = List<String>.from(p['imageUrls']);
                              } else {
                                final singleImage = p['imageUrl'] ?? p['Image_Url'];
                                if (singleImage != null && singleImage.toString().trim().isNotEmpty) {
                                  images = [singleImage.toString().trim()];
                                }
                              }
                            }

                            if (images.length <= 1) return const SizedBox.shrink();

                            return Positioned(
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
                                  children: List.generate(images.length, (index) {
                                    return Container(
                                      margin: EdgeInsets.only(right: index == images.length - 1 ? 0 : 4),
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: _currentImageIndex == index ? primaryGreen : Colors.grey[400],
                                        shape: BoxShape.circle,
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            );
                          }
                        ),
                      ],
                    ),"""

# Perform replacement
start_idx = content.find('Stack(\n                      children: [\n                        Container(\n                          height: 300,')
if start_idx == -1:
    start_idx = content.find('Stack(')
end_idx = content.find('Padding(\n                      padding: const EdgeInsets.all(16.0),', start_idx)

if start_idx != -1 and end_idx != -1:
    # also remove trailing spaces/newlines before Padding
    before = content[:start_idx]
    after = content[end_idx:]
    
    new_full = before + new_stack + "\n\n                    " + after
    with open('lib/screens/customer/product_detail_screen.dart', 'w', encoding='utf-8') as f:
        f.write(new_full)
    print("Updated product detail screen")
else:
    print("Could not find block boundaries")
