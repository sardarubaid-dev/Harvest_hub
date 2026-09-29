import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF2E7D32);
    const Color bgGreen = Color(0xFFF7FBF7);
    const Color darkText = Color(0xFF1F2937);
    const Color greyText = Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: bgGreen,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF81C784).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.eco, color: primaryGreen, size: 16),
                    const SizedBox(width: 8),
                    const Text(
                      'DIRECT-FROM-SOIL COMMERCE',
                      style: TextStyle(
                        color: primaryGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Titles
              const Text(
                'Welcome to HarvestHub',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: darkText,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'How would you like to continue?',
                style: TextStyle(
                  fontSize: 14,
                  color: greyText,
                ),
              ),
              const SizedBox(height: 32),

              // Customer Card
              GestureDetector(
                onTap: () => context.push('/create_account/Customer'),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.transparent),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3F4F6),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.shopping_basket, color: darkText, size: 24),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Text(
                                          'Customer',
                                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkText),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF81C784).withOpacity(0.5),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: const Text('Popular', style: TextStyle(color: primaryGreen, fontSize: 10, fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: const [
                                        Icon(Icons.verified, color: primaryGreen, size: 14),
                                        SizedBox(width: 4),
                                        Text('Local produce & pantry', style: TextStyle(color: primaryGreen, fontSize: 12, fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE5E7EB),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Browse and shop fresh local products directly from nearby farms.',
                              style: TextStyle(color: darkText, fontSize: 13, height: 1.4),
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _buildFeaturePill(Icons.local_shipping_outlined, 'Direct pickup', primaryGreen, null, const Color(0xFFE8F5E9)),
                                _buildFeaturePill(Icons.wb_sunny_outlined, 'Seasonal freshness', primaryGreen, null, const Color(0xFFE8F5E9)),
                                _buildFeaturePill(Icons.verified_user_outlined, 'Verified growers', primaryGreen, null, const Color(0xFFE8F5E9)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(Icons.grass, size: 16, color: greyText),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Over 48 regional growers ac...', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: darkText)),
                                  const Text('Avg. harvest to doorstep: < 1...', style: TextStyle(fontSize: 11, color: greyText)),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: greyText, size: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Farmer Card
              GestureDetector(
                onTap: () => context.push('/create_account/Farmer'),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.transparent),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3F4F6),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.local_florist, color: darkText, size: 24),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Farmer &\nProducer',
                                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkText, height: 1.1),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFE5E7EB),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: const Text('Grower\nPortal', textAlign: TextAlign.center, style: TextStyle(color: greyText, fontSize: 10, fontWeight: FontWeight.bold, height: 1.1)),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: const [
                                          Icon(Icons.agriculture, color: greyText, size: 14),
                                          SizedBox(width: 4),
                                          Text('Independent fields & apiaries', style: TextStyle(color: greyText, fontSize: 12, fontWeight: FontWeight.w600)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE5E7EB),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Manage your harvest listings, daily inventory, customer orders, and stall pickup slots.',
                              style: TextStyle(color: darkText, fontSize: 13, height: 1.4),
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _buildFeaturePill(Icons.money_off, 'Zero commission middleman', greyText, primaryGreen),
                                _buildFeaturePill(Icons.account_balance_wallet_outlined, 'Direct payouts', greyText, primaryGreen),
                                _buildFeaturePill(Icons.notifications_active_outlined, 'Real-time orders', greyText, primaryGreen),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(Icons.store, size: 16, color: greyText),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Instant daily harvest balance...', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: darkText)),
                                  const Text('Automatic CSA batch & crat...', style: TextStyle(fontSize: 11, color: greyText)),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: greyText, size: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Admin Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () => context.go('/login'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text('Continue as Market Administrator', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Login Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account? ', style: TextStyle(color: greyText, fontSize: 13)),
                  GestureDetector(
                    onTap: () => context.go('/login'),
                    child: const Text('Sign In', style: TextStyle(color: primaryGreen, fontSize: 13, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturePill(IconData icon, String text, Color textColor, [Color? iconColor, Color? bgColor]) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor ?? const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor ?? textColor),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(fontSize: 11, color: textColor, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
