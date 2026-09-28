with open('lib/screens/customer/category_products_screen.dart', 'r', encoding='utf-8') as f:
    c = f.read()

old_appbar = '''        appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: darkText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.categoryName,
          style: const TextStyle(color: darkText, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),'''

new_appbar = '''        appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: darkText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.categoryName,
          style: const TextStyle(color: darkText, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.shopping_bag_outlined, color: darkText),
                Consumer<CartProvider>(
                  builder: (context, cart, child) {
                    if (cart.itemCount == 0) return const SizedBox.shrink();
                    return Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: primaryGreen,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${cart.itemCount}',
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
            onPressed: () {
              Navigator.pushNamed(context, '/cart');
            },
          ),
          const SizedBox(width: 8),
        ],
      ),'''

c = c.replace(old_appbar, new_appbar)

with open('lib/screens/customer/category_products_screen.dart', 'w', encoding='utf-8') as f:
    f.write(c)
