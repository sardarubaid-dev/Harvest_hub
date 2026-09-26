import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import 'customer_login_screen.dart';

class RegisterCustomerScreen extends StatefulWidget {
  const RegisterCustomerScreen({Key? key}) : super(key: key);

  @override
  State<RegisterCustomerScreen> createState() => _RegisterCustomerScreenState();
}

class _RegisterCustomerScreenState extends State<RegisterCustomerScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _agreedToTerms = false;
  bool _isLoading = false;

  void _register() async {
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please agree to the Terms of Service')),
      );
      return;
    }

    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      return;
    }

    setState(() => _isLoading = true);
    try {
      final authService = AuthService();
      await authService.signUpCustomer(
        name: _nameController.text,
        email: _emailController.text,
        phone: "+92${_phoneController.text}",
        address: _addressController.text,
        password: _passwordController.text,
      );
      // Registration success, navigate to home or show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account Created Successfully!')),
        );
        Navigator.pop(context); // Go back to login or replace with home
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF2E7D32);
    const Color darkText = Color(0xFF1F2937);
    const Color greyText = Color(0xFF6B7280);
    const Color fieldBg = Colors.white;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF9), // Very light greenish-white
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              // Custom App Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: darkText),
                    onPressed: () => Navigator.pop(context),
                  ),
                  // Small Header Logo
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: primaryGreen,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.eco,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'HarvestHub',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: darkText,
                              height: 1.0,
                            ),
                          ),
                          Text(
                            'LOCAL FARM MARKETPLACE',
                            style: TextStyle(
                              fontSize: 6,
                              fontWeight: FontWeight.bold,
                              color: greyText,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Text(
                    'Create Acco...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: darkText,
                    ),
                  ),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: primaryGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Fresh Direct Honest Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFA5D6A7), // Light green
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.eco_outlined, size: 14, color: primaryGreen),
                    SizedBox(width: 6),
                    Text(
                      'FRESH • DIRECT • HONEST',
                      style: TextStyle(
                        color: primaryGreen,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'Create Your Account',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: darkText,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Join HarvestHub to buy fresh, organic produce\nstraight from local growers.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF4B5563),
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 24),

              // Rooted in Community Card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[300],
                        // Use a local icon/color block if image not available
                        child: const Icon(
                          Icons.shopping_basket,
                          color: Colors.grey,
                          size: 30,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Rooted in Community',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: darkText,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Direct farm gates, zero intermediaries,\nguaranteed harvest-day freshness.',
                            style: TextStyle(
                              fontSize: 12,
                              color: greyText,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Form Fields
              _buildFieldHeader('Full Name', 'Required', null),
              _buildTextField(
                controller: _nameController,
                hint: 'e.g. Ubaid Rehman',
                icon: Icons.person_outline,
              ),

              const SizedBox(height: 16),

              _buildFieldHeader(
                'Email Address',
                'Order receipt & updates',
                null,
              ),
              _buildTextField(
                controller: _emailController,
                hint: 'e.g. ubaid@example.com',
                icon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 16),

              _buildFieldHeader(
                'Mobile Number',
                'Pickup SMS OTPs',
                Icons.chat_outlined,
              ),
              Row(
                children: [
                  Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(
                        0xFFE5E7EB,
                      ), // Light grey for country code
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: const [
                        Text(
                          '+92',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: darkText,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.keyboard_arrow_down,
                          size: 16,
                          color: darkText,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _phoneController,
                      hint: '300 1234567',
                      icon: Icons.phone_android,
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Required for rapid gate pass code & farm locker collection.',
                style: TextStyle(fontSize: 11, color: greyText),
              ),

              const SizedBox(height: 16),

              _buildFieldHeader(
                'Delivery / Pickup Area',
                'Use Current',
                Icons.my_location,
              ),
              _buildTextField(
                controller: _addressController,
                hint: 'e.g. DHA Phase 6, Karachi',
                icon: Icons.location_on_outlined,
                suffixIcon: Icons.send_outlined,
              ),

              const SizedBox(height: 16),

              _buildFieldHeader('Password', null, null),
              _buildTextField(
                controller: _passwordController,
                hint: 'At least 8 characters',
                icon: Icons.lock_outline,
                obscureText: _obscurePassword,
                suffixIcon: _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                onSuffixTap: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              const SizedBox(height: 8),

              // Password Strength Indicator
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1D5DB),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1D5DB),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1D5DB),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1D5DB),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Row(
                    children: [
                      Icon(Icons.shield_outlined, size: 14, color: greyText),
                      SizedBox(width: 4),
                      Text(
                        'Password strength',
                        style: TextStyle(
                          fontSize: 11,
                          color: darkText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Min. 8 characters',
                    style: TextStyle(fontSize: 11, color: greyText),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Terms
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _agreedToTerms,
                      onChanged: (val) =>
                          setState(() => _agreedToTerms = val ?? false),
                      activeColor: primaryGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      side: const BorderSide(color: Color(0xFF9CA3AF)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RichText(
                      text: const TextSpan(
                        text: 'I agree to the ',
                        style: TextStyle(fontSize: 13, color: darkText),
                        children: [
                          TextSpan(
                            text: 'Terms of Service',
                            style: TextStyle(
                              color: primaryGreen,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          TextSpan(text: ' & '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: TextStyle(
                              color: primaryGreen,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Create Account',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, size: 20),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // 100% Free Badge
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.grass,
                        size: 16,
                        color: Colors.orange,
                      ), // Wheat icon placeholder
                      SizedBox(width: 8),
                      Text(
                        '100% Free registration • No hidden fees',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: darkText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Info Cards
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Color(0xFFA5D6A7),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.verified_user_outlined,
                              size: 16,
                              color: primaryGreen,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Verified Farms',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: darkText,
                                  ),
                                ),
                                Text(
                                  '100% organic audits',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: greyText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Color(0xFFA5D6A7),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.local_shipping_outlined,
                              size: 16,
                              color: primaryGreen,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Same-Day Pickup',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: darkText,
                                  ),
                                ),
                                Text(
                                  'Hub lock-in slots',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: greyText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Sign in Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already registered? ',
                    style: TextStyle(fontSize: 13, color: greyText),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CustomerLoginScreen(),
                      ),
                    ),
                    child: const Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: primaryGreen,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldHeader(
    String title,
    String? rightText,
    IconData? rightIcon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
            ),
          ),
          if (rightText != null)
            Row(
              children: [
                if (rightIcon != null) ...[
                  Icon(rightIcon, size: 14, color: const Color(0xFF2E7D32)),
                  const SizedBox(width: 4),
                ],
                Text(
                  rightText,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: rightIcon != null
                        ? const Color(0xFF2E7D32)
                        : const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    IconData? suffixIcon,
    VoidCallback? onSuffixTap,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
          prefixIcon: Icon(icon, color: const Color(0xFF6B7280), size: 20),
          suffixIcon: suffixIcon != null
              ? IconButton(
                  icon: Icon(
                    suffixIcon,
                    color: const Color(0xFF6B7280),
                    size: 20,
                  ),
                  onPressed: onSuffixTap,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}
