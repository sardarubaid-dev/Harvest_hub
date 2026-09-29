with open('lib/screens/customer/customer_home_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

import re

# We need to replace the _buildNavItem function
old_func = """Widget _buildNavItem(int index, IconData icon, IconData activeIcon, bool isBadge) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? const Color(0xFF1B5E20) : const Color(0xFF9CA3AF);

    Widget iconWidget = Icon(isSelected ? activeIcon : icon, color: color, size: 26);

    if (isBadge) {
      iconWidget = Consumer<WishlistProvider>(
        builder: (context, wishlist, child) {
          if (wishlist.wishlistIds.isEmpty) return iconWidget;
          return Badge(
            label: Text(wishlist.wishlistIds.length.toString()),
            backgroundColor: Colors.red,
            child: iconWidget,
          );
        },
      );
    }

    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconWidget,
            const SizedBox(height: 6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 5,
              width: 5,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF1B5E20) : Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }"""

new_func = """Widget _buildNavItem(int index, IconData icon, IconData activeIcon, bool isBadge) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? const Color(0xFF1B5E20) : const Color(0xFF9CA3AF);

    Widget baseIcon = Icon(isSelected ? activeIcon : icon, color: color, size: 26);
    Widget finalIconWidget = baseIcon;

    if (isBadge) {
      finalIconWidget = Consumer<WishlistProvider>(
        builder: (context, wishlist, child) {
          if (wishlist.wishlistIds.isEmpty) return baseIcon;
          return Badge(
            label: Text(wishlist.wishlistIds.length.toString()),
            backgroundColor: Colors.red,
            child: baseIcon,
          );
        },
      );
    }

    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            finalIconWidget,
            const SizedBox(height: 6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 5,
              width: 5,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF1B5E20) : Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }"""

if old_func in content:
    content = content.replace(old_func, new_func)
    print("Replaced successfully.")
else:
    print("Could not find the function to replace. Using regex.")
    
with open('lib/screens/customer/customer_home_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
