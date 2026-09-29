import re

file_path = 'lib/screens/customer/customer_home_screen.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

with open('header_old.txt', 'r', encoding='utf-8') as f:
    old_code = f.read()

new_code = """  Widget _buildGlobalHeader(
    Color primaryGreen,
    Color darkText,
    Color greyText,
    String userName,
  ) {
    String title = '';
    
    switch (_currentIndex) {
      case 1:
        title = 'Fresh Market';
        break;
      case 2:
        title = 'Categories';
        break;
      case 3:
        title = 'My Wishlist';
        break;
      case 4:
        title = 'Order History';
        break;
      default:
        title = 'HarvestHub';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Color(0xFF191D19),
              letterSpacing: -0.5,
            ),
          ),
          Row(
            children: [
              if (_currentIndex == 1 || _currentIndex == 2)
                Container(
                  margin: const EdgeInsets.only(right: 12),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF4F7F4),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.search, color: Color(0xFF191D19), size: 22),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SearchFilterScreen()),
                      );
                    },
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(10),
                  ),
                ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartScreen()),
                  ).then((_) => setState(() {}));
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primaryGreen.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(Icons.shopping_cart_outlined, color: primaryGreen, size: 24),
                      Consumer<CartProvider>(
                        builder: (context, cartProv, child) {
                          if (cartProv.itemCount == 0) return const SizedBox.shrink();
                          return Positioned(
                            right: -6,
                            top: -6,
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${cartProv.itemCount}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
"""

if old_code in content:
    content = content.replace(old_code, new_code)
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)
    print("Replaced global header")
else:
    print("Old code not found in file")
