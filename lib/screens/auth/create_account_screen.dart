import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:harvest_hub/theme/app_theme.dart';
import 'package:harvest_hub/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

class CreateAccountScreen extends StatefulWidget {
  final String role;

  const CreateAccountScreen({
    super.key,
    this.role = 'Customer',
  });

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _farmNameController = TextEditingController();
  final _farmDescController = TextEditingController();

  late String _selectedRole;
  bool _obscurePassword = true;
  bool _agreedToTerms = false;
  int _passwordScore = 0;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.role == 'Admin' ? 'Customer' : widget.role;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _farmNameController.dispose();
    _farmDescController.dispose();
    super.dispose();
  }

  void _updatePasswordStrength(String val) {
    setState(() {
      if (val.isEmpty) {
        _passwordScore = 0;
        return;
      }
      int score = 0;
      if (val.length >= 6) score++;
      if (val.length >= 8) score++;
      if (RegExp(r'[0-9]').hasMatch(val) && RegExp(r'[a-zA-Z]').hasMatch(val)) score++;
      if (RegExp(r'[^a-zA-Z0-9]').hasMatch(val)) score++;
      _passwordScore = score;
    });
  }

  void _handleCreateAccount() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the Terms of Service & Privacy Policy.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    bool success = false;

    if (_selectedRole == 'Farmer') {
      success = await authProvider.signUpFarmer(
        email: _emailController.text,
        password: _passwordController.text,
        name: _nameController.text,
        farmName: _farmNameController.text.trim().isNotEmpty
            ? _farmNameController.text
            : "${_nameController.text}'s Farm",
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
      _showSuccessDialog();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Registration failed. Try again.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle_outline, color: AppColors.onPrimary, size: 36),
                ),
                Text(
                  'Account Created!',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontFamily: 'Inter',
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Your account has been registered in HarvestHub database. You are now logged in as $_selectedRole.",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontFamily: 'Inter',
                    color: AppColors.onSurfaceVariant,
                    fontSize: 14,
                  ),
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
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Go to Dashboard', style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Register $_selectedRole Account',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: AppColors.onSurface,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: ['Customer', 'Farmer'].map((role) {
                      final isSelected = _selectedRole == role;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedRole = role;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              role,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : AppColors.onSurface,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  'Full Name',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontFamily: 'Inter', fontWeight: FontWeight.w600, color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameController,
                  decoration: _buildInputDecoration('e.g. Ubaid Rehman', Icons.person_outline),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Full name required' : null,
                ),
                const SizedBox(height: 16),

                Text(
                  'Email Address',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontFamily: 'Inter', fontWeight: FontWeight.w600, color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _buildInputDecoration('e.g. ubaid@example.com', Icons.mail_outline),
                  validator: (val) => val == null || !val.contains('@') ? 'Valid email required' : null,
                ),
                const SizedBox(height: 16),

                Text(
                  'Mobile Number',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontFamily: 'Inter', fontWeight: FontWeight.w600, color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: _buildInputDecoration('e.g. 0300 1234567', Icons.phone_iphone),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Phone number required' : null,
                ),
                const SizedBox(height: 16),

                if (_selectedRole == 'Farmer') ...[
                  Text(
                    'Farm / Business Name',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontFamily: 'Inter', fontWeight: FontWeight.w600, color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _farmNameController,
                    decoration: _buildInputDecoration('e.g. Green Valley Farm', Icons.storefront_outlined),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Farm name required' : null,
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Farm Description',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontFamily: 'Inter', fontWeight: FontWeight.w600, color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _farmDescController,
                    maxLines: 2,
                    decoration: _buildInputDecoration('Organic produce grower specializing in fresh fruits & vegetables.', Icons.description_outlined),
                  ),
                  const SizedBox(height: 16),
                ],

                Text(
                  _selectedRole == 'Farmer' ? 'Farm Location / Market Address' : 'Delivery / Home Address',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontFamily: 'Inter', fontWeight: FontWeight.w600, color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _addressController,
                  decoration: _buildInputDecoration('e.g. Sector 4, Green Valley', Icons.location_on_outlined),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Address required' : null,
                ),
                const SizedBox(height: 16),

                Text(
                  'Password',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontFamily: 'Inter', fontWeight: FontWeight.w600, color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  onChanged: _updatePasswordStrength,
                  decoration: InputDecoration(
                    hintText: 'At least 6 characters',
                    hintStyle: const TextStyle(color: AppColors.outline, fontSize: 15),
                    prefixIcon: const Icon(Icons.lock_outline, color: AppColors.outline, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: AppColors.outline,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    fillColor: AppColors.surfaceContainerLowest,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (val) => val == null || val.length < 6 ? 'Minimum 6 characters required' : null,
                ),
                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _buildStrengthBar(1), const SizedBox(width: 6),
                          _buildStrengthBar(2), const SizedBox(width: 6),
                          _buildStrengthBar(3), const SizedBox(width: 6),
                          _buildStrengthBar(4),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(_getStrengthIcon(), size: 13, color: _getStrengthColor()),
                              const SizedBox(width: 4),
                              Text(_getStrengthLabel(), style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                fontFamily: 'Inter', color: _getStrengthColor(),
                              )),
                            ],
                          ),
                          Text(_getStrengthAdvice(), style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontFamily: 'Inter', fontSize: 12, color: AppColors.outline,
                          )),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 20,
                        height: 20,
                        margin: const EdgeInsets.only(top: 2),
                        decoration: BoxDecoration(
                          color: _agreedToTerms ? AppColors.primary : AppColors.surface,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: _agreedToTerms ? AppColors.primary : AppColors.outline,
                            width: 1.5,
                          ),
                        ),
                        child: _agreedToTerms 
                          ? const Icon(Icons.check, size: 16, color: AppColors.onPrimary)
                          : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'I agree to the Terms of Service & Privacy Policy.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.onSurface,
                          fontFamily: 'Inter',
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: authProvider.isLoading ? null : _handleCreateAccount,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryContainer,
                      foregroundColor: AppColors.onPrimary,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: authProvider.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            'Create $_selectedRole Account',
                            style: const TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.outline, fontSize: 15),
      prefixIcon: Icon(icon, color: AppColors.outline, size: 20),
      fillColor: AppColors.surfaceContainerLowest,
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _buildStrengthBar(int barIndex) {
    Color barColor = AppColors.surfaceDim;
    if (_passwordScore > 0) {
      if (_passwordScore == 1 && barIndex == 1) {
        barColor = AppColors.error;
      } else if (_passwordScore == 2 && barIndex <= 2) {
        barColor = AppColors.errorContainer;
      } else if (_passwordScore == 3 && barIndex <= 3) {
        barColor = AppColors.secondary;
      } else if (_passwordScore >= 4) {
        barColor = AppColors.primary;
      }
    }
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 6,
        decoration: BoxDecoration(
          color: barColor,
          borderRadius: BorderRadius.circular(99),
        ),
      ),
    );
  }

  Color _getStrengthColor() {
    if (_passwordScore == 0) return AppColors.outline;
    if (_passwordScore == 1) return AppColors.error;
    if (_passwordScore == 2) return AppColors.secondary;
    if (_passwordScore == 3) return AppColors.secondary;
    return AppColors.primary;
  }

  IconData _getStrengthIcon() {
    if (_passwordScore >= 4) return Icons.verified_user_outlined;
    return Icons.shield_outlined;
  }

  String _getStrengthLabel() {
    if (_passwordScore == 0) return 'Password strength';
    if (_passwordScore == 1) return 'Weak';
    if (_passwordScore == 2) return 'Fair';
    if (_passwordScore == 3) return 'Good';
    return 'Strong • 8+ characters';
  }

  String _getStrengthAdvice() {
    if (_passwordScore == 0) return 'Min. 6 characters';
    if (_passwordScore == 1) return 'Add numbers & letters';
    if (_passwordScore == 2) return 'Make it 8+ chars';
    if (_passwordScore == 3) return 'Add special symbol';
    return 'Excellent!';
  }
}

