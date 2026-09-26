import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';

import 'package:go_router/go_router.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    const Color primaryGreen = Color(0xFF2E7D32);
    const Color background = Color(0xFFF9FBF9);
    const Color darkText = Color(0xFF1F2937);
    const Color greyText = Color(0xFF6B7280);

    if (user == null) {
      return Scaffold(
        backgroundColor: background,
        appBar: AppBar(
          title: const Text(
            'My Profile',
            style: TextStyle(color: darkText, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_outline, size: 80, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'You are not logged in.',
                style: TextStyle(fontSize: 18, color: darkText),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  context.push('/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Login to View Profile',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                top: 40,
                bottom: 30,
                left: 20,
                right: 20,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: primaryGreen.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: primaryGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: darkText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: const TextStyle(fontSize: 14, color: greyText),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Settings List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildListTile(
                    Icons.shopping_bag_outlined,
                    'My Orders',
                    () {},
                  ),
                  _buildListTile(
                    Icons.location_on_outlined,
                    'Shipping Addresses',
                    () {},
                  ),
                  _buildListTile(
                    Icons.payment_outlined,
                    'Payment Methods',
                    () {},
                  ),
                  _buildListTile(
                    Icons.notifications_outlined,
                    'Notifications',
                    () {},
                  ),
                  _buildListTile(Icons.security_outlined, 'Security', () {}),
                  _buildListTile(Icons.help_outline, 'Help & Support', () {}),
                  const SizedBox(height: 20),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text(
                      'Log Out',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () async {
                      await authProvider.logout();
                      Navigator.of(context)
                          .pushNamedAndRemoveUntil('/', (route) => false);
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    tileColor: Colors.white,
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          leading: Icon(icon, color: const Color(0xFF2E7D32)),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Color(0xFF1F2937),
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.grey,
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
