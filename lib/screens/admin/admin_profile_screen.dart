import 'package:flutter/material.dart';
import 'package:harvest_hub/theme/app_theme.dart';
import 'package:harvest_hub/services/database_service.dart';
import 'package:harvest_hub/services/auth_service.dart';
import 'package:harvest_hub/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  final _dbService = DatabaseService();
  final _authService = AuthService();
  
  UserModel? _currentUser;
  bool _isLoading = true;
  bool _isSaving = false;

  final _formKey = GlobalKey<FormState>();
  
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final uid = _authService.currentUserId;
    if (uid != null) {
      final user = await _dbService.getUser(uid);
      if (user != null) {
        setState(() {
          _currentUser = user;
          _nameCtrl.text = user.name;
          _phoneCtrl.text = user.phone ?? '';
          _addressCtrl.text = user.address ?? '';
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate() || _currentUser == null) return;

    setState(() => _isSaving = true);
    
    try {
      final updatedUser = _currentUser!.copyWith(
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
      );

      await _dbService.updateUser(updatedUser);
      
      if (mounted) {
        setState(() => _currentUser = updatedUser);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _deleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account?'),
        content: const Text(
            'Are you sure you want to delete your administrator account? This action cannot be undone and you will lose access to the system immediately.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete Permanently', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true && _currentUser != null && mounted) {
      try {
        await _dbService.deleteUser(_currentUser!.uid);
        await FirebaseAuth.instance.currentUser?.delete(); // Deletes from Auth
        if (mounted) {
          context.go('/login');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete account: $e\nYou may need to log in again to verify your identity.'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: readOnly ? Colors.grey.shade600 : AppColors.onSurface,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14),
          prefixIcon: Icon(icon, color: readOnly ? Colors.grey : AppColors.primary, size: 22),
          filled: true,
          fillColor: readOnly ? Colors.grey.shade100 : Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.error, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.error, width: 2),
          ),
        ),
        validator: readOnly ? null : (v) => v == null || v.trim().isEmpty ? 'Required' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Admin Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.onSurface,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _currentUser == null
              ? const Center(child: Text('Profile not found'))
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      // Header Profile Section
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5))
                          ],
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(32),
                            bottomRight: Radius.circular(32),
                          ),
                        ),
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 50,
                                  backgroundColor: AppColors.primaryContainer,
                                  backgroundImage: _currentUser!.photoUrl != null
                                      ? NetworkImage(_currentUser!.photoUrl!)
                                      : null,
                                  child: _currentUser!.photoUrl == null
                                      ? Text(
                                          _currentUser!.name.isNotEmpty ? _currentUser!.name[0].toUpperCase() : 'A',
                                          style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
                                        )
                                      : null,
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.edit, color: Colors.white, size: 16),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _currentUser!.name,
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.onSurface),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.secondaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _currentUser!.role.toUpperCase(),
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.onSecondaryContainer),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),

                      // Edit Form Section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Personal Information',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: TextEditingController(text: _currentUser!.email),
                                label: 'Email Address',
                                icon: Icons.email_outlined,
                                readOnly: true, // Email is generally read-only unless re-auth is provided
                              ),
                              _buildTextField(
                                controller: _nameCtrl,
                                label: 'Full Name',
                                icon: Icons.person_outline,
                              ),
                              _buildTextField(
                                controller: _phoneCtrl,
                                label: 'Phone Number',
                                icon: Icons.phone_outlined,
                              ),
                              _buildTextField(
                                controller: _addressCtrl,
                                label: 'Address / Location',
                                icon: Icons.location_on_outlined,
                              ),

                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isSaving ? null : _saveProfile,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    padding: const EdgeInsets.symmetric(vertical: 18),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    elevation: 4,
                                    shadowColor: AppColors.primary.withOpacity(0.5),
                                  ),
                                  child: _isSaving
                                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                      : const Text('Save Profile Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: () async {
                                    await FirebaseAuth.instance.signOut();
                                    if (mounted) context.go('/login');
                                  },
                                  icon: const Icon(Icons.logout, color: AppColors.primary),
                                  label: const Text('Log Out', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 18),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    side: const BorderSide(color: AppColors.primary, width: 1.5),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 48),
                      
                      // Danger Zone
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Danger Zone',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.error),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppColors.errorContainer,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.error.withOpacity(0.3)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Delete Account',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.error),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Once you delete your account, there is no going back. Please be certain.',
                                    style: TextStyle(fontSize: 13, color: AppColors.error),
                                  ),
                                  const SizedBox(height: 16),
                                  OutlinedButton.icon(
                                    onPressed: _deleteAccount,
                                    icon: const Icon(Icons.delete_forever, color: AppColors.error),
                                    label: const Text('Delete Account', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: AppColors.error),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 48),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
