with open('lib/screens/customer/customer_home_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

import re

# 1. We need to add a helper function for _buildNavItem inside _CustomerHomeScreenState
nav_item_func = """
  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, bool isBadge) {
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
      child: SizedBox(
        width: 50,
        height: 50,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconWidget,
            const SizedBox(height: 4),
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
  }
"""

# Insert it right before _buildGlobalHeader
idx = content.find("Widget _buildGlobalHeader(")
if idx != -1:
    content = content[:idx] + nav_item_func + "\n  " + content[idx:]

# 2. Replace the Scaffold's bottomNavigationBar and floatingActionButton
# First, find floatingActionButton:
start_fab = content.find("floatingActionButton:")
end_nav = content.find("],", content.find("items:", start_fab))
end_nav = content.find("),", end_nav)
end_nav = content.find(";", end_nav) + 1 # wait, bottomNavigationBar: ...),

# Actually let's use regex
pattern = r"floatingActionButton: GestureDetector\([\s\S]*?bottomNavigationBar: BottomNavigationBar\([\s\S]*?\],\n\s*\),\n\s*\);"

new_nav = """extendBody: true,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: GestureDetector(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 20,
              ),
              child: const ChatbotScreen(),
            ),
          );
        },
        child: Container(
          width: 56,
          height: 56,
          margin: const EdgeInsets.only(top: 20),
          decoration: BoxDecoration(
            color: const Color(0xFF2E7D32),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2E7D32).withOpacity(0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: Colors.white, width: 3),
          ),
          child: const Padding(
            padding: EdgeInsets.all(2.0),
            child: HarviAvatar(expression: HarviExpression.idle, size: 50),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BottomAppBar(
            color: Colors.white,
            elevation: 0,
            shape: const CircularNotchedRectangle(),
            notchMargin: 8,
            child: SizedBox(
              height: 65,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 8),
                      _buildNavItem(0, Icons.home_outlined, Icons.home, false),
                      const SizedBox(width: 12),
                      _buildNavItem(1, Icons.storefront_outlined, Icons.storefront, false),
                    ],
                  ),
                  Row(
                    children: [
                      _buildNavItem(3, Icons.favorite_border, Icons.favorite, true),
                      const SizedBox(width: 12),
                      _buildNavItem(5, Icons.person_outline, Icons.person, false),
                      const SizedBox(width: 8),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );"""

content = re.sub(pattern, new_nav, content)

with open('lib/screens/customer/customer_home_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
print("Updated bottom nav")
