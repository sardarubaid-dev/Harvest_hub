with open('lib/screens/customer/customer_home_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

import re

old_nav = """bottomNavigationBar: Container(
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
      ),"""

new_nav = """bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        child: Container(
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
                        const SizedBox(width: 12),
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
                        const SizedBox(width: 12),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),"""

if old_nav in content:
    content = content.replace(old_nav, new_nav)
    print("Replaced nav padding")
else:
    print("Could not find old nav")

with open('lib/screens/customer/customer_home_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
