import re

with open('lib/screens/customer/wishlist_screen.dart', 'r', encoding='utf-8') as f:
    c = f.read()

c = c.replace("import '../../services/database_service.dart';", "import '../../services/database_service.dart';\nimport '../../providers/wishlist_provider.dart';")

old_toggle = '''  void _toggleFavorite(String productId) async {
    final uid = _currentUid;
    if (uid == null) return;
    await _dbService.toggleWishlistProduct(uid, productId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Removed from Wishlist'),
        duration: Duration(seconds: 1),
      ),
    );
  }'''

new_toggle = '''  void _toggleFavorite(String productId) {
    Provider.of<WishlistProvider>(context, listen: false).toggleWishlist(productId);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Wishlist Updated'),
        duration: Duration(seconds: 1),
      ),
    );
  }'''
c = c.replace(old_toggle, new_toggle)

old_body = '''      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('customers').doc(uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: CircularProgressIndicator());
          }
          final customerData = snapshot.data!.data() as Map<String, dynamic>?;
          final wishlistIds = List<String>.from(customerData?['wishlist'] ?? []);'''

new_body = '''      body: Consumer<WishlistProvider>(
        builder: (context, wishlistProvider, _) {
          final wishlistIds = wishlistProvider.wishlistIds;'''
c = c.replace(old_body, new_body)

c = c.replace('''            builder: (context, prodSnapshot) {
              if (!prodSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final allProducts = prodSnapshot.data!;
              final favoriteProducts = allProducts.where((p) => wishlistIds.contains(p.id)).toList();''', '''            builder: (context, prodSnapshot) {
              if (!prodSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final allProducts = prodSnapshot.data!;
              final favoriteProducts = allProducts.where((p) => wishlistIds.contains(p.id)).toList();''')

# Now fix the closing brackets for Consumer
c = c.replace('''          return StreamBuilder<List<ProductModel>>(
            stream: _dbService.streamAllProducts(),
            builder: (context, prodSnapshot) {
              if (!prodSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final allProducts = prodSnapshot.data!;
              final favoriteProducts = allProducts.where((p) => wishlistIds.contains(p.id)).toList();''', '''          return StreamBuilder<List<ProductModel>>(
            stream: _dbService.streamAllProducts(),
            builder: (context, prodSnapshot) {
              if (!prodSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final allProducts = prodSnapshot.data!;
              final favoriteProducts = allProducts.where((p) => wishlistIds.contains(p.id)).toList();''')

# Replace the closing brackets of StreamBuilder to match Consumer
# Actually let's just do a string replace for the end of the file.
# The original file ended with:
#             },
#           );
#         },
#       ),
#     );
#   }
# }
c = c.replace('''            },
          );
        },
      ),
    );
  }
}''', '''            },
          );
        },
      ),
    );
  }
}''')

with open('lib/screens/customer/wishlist_screen.dart', 'w', encoding='utf-8') as f:
    f.write(c)

print("Done")
