import re

with open('lib/screens/customer/customer_home_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Pattern to replace from floatingActionButtonLocation up to the end of bottomNavigationBar
pattern = r"floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,[\s\S]*?bottomNavigationBar: Padding\([\s\S]*?child: Container\([\s\S]*?child: ClipRRect\([\s\S]*?child: BottomAppBar\([\s\S]*?\),[\s\S]*?\),[\s\S]*?\),[\s\S]*?\),"

new_nav = """floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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
          ),
          child: const Padding(
            padding: EdgeInsets.all(4.0),
            child: HarviAvatar(expression: HarviExpression.idle, size: 48),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        elevation: 10,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        padding: EdgeInsets.zero,
        child: SizedBox(
          height: 65,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavItem(0, Icons.home_outlined, Icons.home, false),
                    _buildNavItem(1, Icons.storefront_outlined, Icons.storefront, false),
                    _buildNavItem(2, Icons.grid_view_outlined, Icons.grid_view, false),
                  ],
                ),
              ),
              const SizedBox(width: 48), // Space for FAB
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavItem(3, Icons.favorite_border, Icons.favorite, true),
                    _buildNavItem(4, Icons.receipt_long_outlined, Icons.receipt_long, false),
                    _buildNavItem(5, Icons.person_outline, Icons.person, false),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),"""

if re.search(pattern, content):
    content = re.sub(pattern, new_nav, content)
    with open('lib/screens/customer/customer_home_screen.dart', 'w', encoding='utf-8') as f:
        f.write(content)
    print("Replaced nav successfully.")
else:
    print("Could not find pattern!")

