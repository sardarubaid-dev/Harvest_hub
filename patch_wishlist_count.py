with open('lib/screens/customer/customer_home_screen.dart', 'r', encoding='utf-8') as f:
    c = f.read()

old_items = '''        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront_outlined),
            activeIcon: Icon(Icons.storefront),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'Wishlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],'''

new_items = '''        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.storefront_outlined),
            activeIcon: Icon(Icons.storefront),
            label: 'Products',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.grid_view),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Consumer<WishlistProvider>(
              builder: (context, wishlist, _) {
                if (wishlist.wishlistIds.isEmpty) {
                  return const Icon(Icons.favorite_border);
                }
                return Badge(
                  label: Text(wishlist.wishlistIds.length.toString()),
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.favorite_border),
                );
              },
            ),
            activeIcon: Consumer<WishlistProvider>(
              builder: (context, wishlist, _) {
                if (wishlist.wishlistIds.isEmpty) {
                  return const Icon(Icons.favorite);
                }
                return Badge(
                  label: Text(wishlist.wishlistIds.length.toString()),
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.favorite),
                );
              },
            ),
            label: 'Wishlist',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],'''

c = c.replace(old_items, new_items)

with open('lib/screens/customer/customer_home_screen.dart', 'w', encoding='utf-8') as f:
    f.write(c)

print("Done with wishlist count")
