import re

file_path = 'lib/screens/customer/profile_screen.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Add WishlistScreen import
if "import 'wishlist_screen.dart';" not in content:
    content = content.replace("import 'orders_screen.dart';", "import 'orders_screen.dart';\nimport 'wishlist_screen.dart';")

# 2. Fix settings icon
old_settings = """IconButton(
                        icon: const Icon(Icons.settings_outlined, color: Colors.white),
                        onPressed: () {},
                      )"""
new_settings = """IconButton(
                        icon: const Icon(Icons.settings_outlined, color: Colors.white),
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())),
                      )"""
content = content.replace(old_settings, new_settings)

# 3. Fix Stat cards
old_fav = """_buildStatCard(
                      'Favorites',
                      '${customer?.wishlist.length ?? 0}',
                      Icons.favorite,
                      Colors.red.shade400,
                    ),"""
new_fav = """GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WishlistScreen())),
                      child: _buildStatCard(
                        'Favorites',
                        '${customer?.wishlist.length ?? 0}',
                        Icons.favorite,
                        Colors.red.shade400,
                      ),
                    ),"""
content = content.replace(old_fav, new_fav)

old_ord = """_buildStatCard(
                          'Total Orders',
                          '$ordersCount',
                          Icons.shopping_bag,
                          primaryGreen,
                        );"""
new_ord = """GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OrdersScreen(onShopNow: () => Navigator.pop(context)))),
                          child: _buildStatCard(
                            'Total Orders',
                            '$ordersCount',
                            Icons.shopping_bag,
                            primaryGreen,
                          ),
                        );"""
content = content.replace(old_ord, new_ord)

# 4. Remove Help & Support section completely
old_help = """const SizedBox(height: 24),
                  const Text('Help & Support', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkText)),
                  const SizedBox(height: 16),
                  _buildMenuCard([
                    _buildListTile(
                      icon: Icons.security_outlined,
                      title: 'Privacy & Security',
                      onTap: () {},
                    ),
                    _buildDivider(),
                    _buildListTile(
                      icon: Icons.help_outline,
                      title: 'Help Center',
                      onTap: () {},
                    ),
                  ]),
                  const SizedBox(height: 32),"""
new_help = """const SizedBox(height: 32),"""
content = content.replace(old_help, new_help)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)
print("Profile fixes done.")
