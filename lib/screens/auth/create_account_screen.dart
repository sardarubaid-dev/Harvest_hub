import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

class CreateAccountScreen extends StatefulWidget {
  final String role;
  const CreateAccountScreen({super.key, required this.role});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  // Farmer specific
  final _farmNameController = TextEditingController();
  final _farmDescController = TextEditingController();

  bool _obscurePassword = true;
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _farmNameController.dispose();
    _farmDescController.dispose();
    super.dispose();
  }

  void _handleCreateAccount() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the Terms of Service & Privacy Policy.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    bool success = false;

    if (widget.role == 'Farmer') {
      success = await authProvider.signUpFarmer(
        email: _emailController.text,
        password: _passwordController.text,
        name: _nameController.text,
        farmName: _farmNameController.text.trim().isNotEmpty
            ? _farmNameController.text
            : "\'s Farm",
        description: _farmDescController.text,
        location: _addressController.text,
        contactNumber: _phoneController.text,
      );
    } else {
      success = await authProvider.signUpCustomer(
        email: _emailController.text,
        password: _passwordController.text,
        name: _nameController.text,
        phone: _phoneController.text,
        address: _addressController.text,
      );
    }

    if (success && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFF2E7D32),
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Account Created!',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your \ account has been successfully created.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        context.go('/');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Go to Dashboard',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authProvider.errorMessage ?? 'Registration failed. Try again.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    const primaryGreen = Color(0xFF2E7D32);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.eco, color: primaryGreen, size: 24),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'HarvestHub',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'LOCAL FARM MARKETPLACE',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 8,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              // Logo
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryGreen,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.eco, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 12),
              const Text(
                'HarvestHub',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                'LOCAL FARM MARKETPLACE',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 10,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 16),

              // Pill
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '? Step 2 of 2 ?',
                  style: TextStyle(
                    color: primaryGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Titles
              Text(
                'Create \ Account',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Join your local farm network today.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),

              // Form Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(
                        'Full Name',
                        _nameController,
                        Icons.person_outline,
                      ),
                      _buildTextField(
                        'Email Address',
                        _emailController,
                        Icons.mail_outline,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      _buildTextField(
                        'Phone Number',
                        _phoneController,
                        Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                      _buildTextField(
                        'Address / Location',
                        _addressController,
                        Icons.location_on_outlined,
                      ),

                      if (widget.role == 'Farmer') ...[
                        _buildTextField(
                          'Farm Name (Optional)',
                          _farmNameController,
                          Icons.agriculture_outlined,
                          isRequired: false,
                        ),
                        _buildTextField(
                          'Farm Description (Optional)',
                          _farmDescController,
                          Icons.description_outlined,
                          isRequired: false,
                          maxLines: 3,
                        ),
                      ],

                      const Text(
                        'Password',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: '������������',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                            color: Colors.grey,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: Colors.grey,
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                          ),
                        ),
                        validator: (val) => val == null || val.length < 6
                            ? 'Password must be at least 6 characters'
                            : null,
                      ),
                      const SizedBox(height: 24),

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
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text.rich(
                              TextSpan(
                                text: 'I agree to the ',
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 13,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Terms of Service',
                                    style: const TextStyle(
                                      color: primaryGreen,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const TextSpan(text: ' and '),
                                  TextSpan(
                                    text: 'Privacy Policy',
                                    style: const TextStyle(
                                      color: primaryGreen,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: authProvider.isLoading
                              ? null
                              : _handleCreateAccount,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryGreen,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: authProvider.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Create Account',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.shield_outlined,
                    color: primaryGreen,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Secure community registration',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool isRequired = true,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: 'Enter $label',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              prefixIcon: maxLines == 1 ? Icon(icon, color: Colors.grey) : null,
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(
                vertical: 16,
                horizontal: maxLines == 1 ? 0 : 16,
              ),
            ),
            validator: (val) {
              if (isRequired && (val == null || val.isEmpty))
                return '$label  is required';
              return null;
            },
          ),
        ],
      ),
    );
  }
}
