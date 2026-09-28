import 'package:flutter/material.dart';
import 'package:harvest_hub/theme/app_theme.dart';
import 'package:harvest_hub/services/database_service.dart';
import 'package:harvest_hub/models/farmer_model.dart';

class AdminOnboardFarmerScreen extends StatefulWidget {
  const AdminOnboardFarmerScreen({super.key});

  @override
  State<AdminOnboardFarmerScreen> createState() =>
      _AdminOnboardFarmerScreenState();
}

class _AdminOnboardFarmerScreenState extends State<AdminOnboardFarmerScreen> {
  final _dbService = DatabaseService();
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _isSubmitting = false;

  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();

  // Personal Info
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  // Farm Details
  final _businessNameCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _businessNameCtrl.dispose();
    _locationCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 0 && !_formKey1.currentState!.validate()) return;
    if (_currentStep == 1 && !_formKey2.currentState!.validate()) return;

    if (_currentStep < 2) {
      setState(() => _currentStep++);
      _pageController.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOutCubic);
    } else {
      _submit();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOutCubic);
    } else {
      Navigator.pop(context);
    }
  }

  void _submit() async {
    setState(() => _isSubmitting = true);
    try {
      final mockUid = 'FARMER_INVITE_${DateTime.now().millisecondsSinceEpoch}';

      final farmer = FarmerModel(
        id: mockUid,
        userId: mockUid,
        farmName: _businessNameCtrl.text.trim(),
        description: _descriptionCtrl.text.trim(),
        location: _locationCtrl.text.trim(),
        contactNumber: _phoneCtrl.text.trim(),
        isApproved: true,
        createdAt: DateTime.now(),
      );

      await _dbService.updateFarmer(farmer);

      if (mounted) {
        _showSuccessSheet();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSuccessSheet() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle,
                  color: AppColors.primary, size: 64),
            ),
            const SizedBox(height: 24),
            const Text(
              'Success!',
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.onSurface),
            ),
            const SizedBox(height: 12),
            Text(
              '${_businessNameCtrl.text} has been successfully onboarded and is now live.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 16, color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // close sheet
                  Navigator.pop(context); // close screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Return to Directory',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          labelText: label,
          labelStyle:
              const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14),
          prefixIcon: Icon(icon, color: AppColors.primary, size: 22),
          filled: true,
          fillColor: Colors.grey.shade50,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide:
                const BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.redAccent, width: 2),
          ),
        ),
        validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
      ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Personal Info',
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.onSurface),
            ),
            const SizedBox(height: 8),
            const Text(
              'Who is managing this farm?',
              style: TextStyle(
                  fontSize: 16, color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 32),
            _buildTextField(
                controller: _nameCtrl,
                label: 'Full Name',
                icon: Icons.person_outline),
            _buildTextField(
                controller: _emailCtrl,
                label: 'Email Address',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress),
            _buildTextField(
                controller: _phoneCtrl,
                label: 'Phone Number',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Farm Details',
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.onSurface),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tell us about their business.',
              style: TextStyle(
                  fontSize: 16, color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 32),
            _buildTextField(
                controller: _businessNameCtrl,
                label: 'Farm / Business Name',
                icon: Icons.storefront_outlined),
            _buildTextField(
                controller: _locationCtrl,
                label: 'Location / City',
                icon: Icons.location_on_outlined),
            _buildTextField(
                controller: _descriptionCtrl,
                label: 'Farm Description',
                icon: Icons.description_outlined,
                maxLines: 3),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.onSurfaceVariant)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Review & Submit',
            style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: AppColors.onSurface),
          ),
          const SizedBox(height: 8),
          const Text(
            'Confirm the details before making the profile live.',
            style: TextStyle(fontSize: 16, color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Column(
              children: [
                _buildReviewRow(
                    'Full Name', _nameCtrl.text, Icons.person_outline),
                _buildReviewRow(
                    'Email Address', _emailCtrl.text, Icons.email_outlined),
                _buildReviewRow(
                    'Phone Number', _phoneCtrl.text, Icons.phone_outlined),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(height: 1),
                ),
                _buildReviewRow('Business Name', _businessNameCtrl.text,
                    Icons.storefront_outlined),
                _buildReviewRow('Location', _locationCtrl.text,
                    Icons.location_on_outlined),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                    onPressed: _prevStep,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      shadowColor: Colors.black12,
                      elevation: 2,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text('Onboard Farmer',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface)),
                ],
              ),
            ),

            // Progress Indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: List.generate(3, (index) {
                  final isActive = index <= _currentStep;
                  return Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: EdgeInsets.only(right: index == 2 ? 0 : 8),
                      height: 6,
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.primary
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Page View
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStep1(),
                  _buildStep2(),
                  _buildStep3(),
                ],
              ),
            ),

            // Bottom Actions
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  )
                ],
              ),
              child: Row(
                children: [
                  if (_currentStep > 0) ...[
                    Expanded(
                      flex: 1,
                      child: OutlinedButton(
                        onPressed: _isSubmitting ? null : _prevStep,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          side: const BorderSide(color: Colors.grey),
                        ),
                        child: const Text('Back',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.onSurface)),
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _nextStep,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                        shadowColor: AppColors.primary.withOpacity(0.5),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : Text(
                              _currentStep == 2 ? 'Launch Farmer' : 'Next Step',
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
