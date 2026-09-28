import re

with open('lib/screens/customer/category_products_screen.dart', 'r', encoding='utf-8') as f:
    c = f.read()

pattern = re.compile(r'appBar:\s*AppBar\(\s*backgroundColor:\s*Colors\.white,\s*elevation:\s*0\.5,\s*leading:\s*IconButton\(\s*icon:\s*const\s*Icon\(Icons\.arrow_back,\s*color:\s*darkText\),\s*onPressed:\s*\(\)\s*=>\s*Navigator\.pop\(context\),\s*\),\s*title:\s*Text\(\s*widget\.categoryName,\s*style:\s*const\s*TextStyle\(color:\s*darkText,\s*fontWeight:\s*FontWeight\.bold\),\s*\),\s*centerTitle:\s*true,\s*\),')

new_appbar = '''appBar: AppBar(
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
                          color: Color(0xFF2E7D32),
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
              // Assume cart screen is reachable
              Navigator.pushNamed(context, '/cart_screen_if_exists'); // This is risky if route is not defined
            },
          ),
          const SizedBox(width: 8),
        ],
      ),'''

# Actually wait, instead of pushing named route, let's just push MaterialPageRoute to CartScreen
new_appbar_safe = '''appBar: AppBar(
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
                          color: Color(0xFF2E7D32),
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

c, count = pattern.subn(new_appbar_safe, c)
print(f"Replaced {count} instances in category")

with open('lib/screens/customer/category_products_screen.dart', 'w', encoding='utf-8') as f:
    f.write(c)

