import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/market_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../theme/app_theme.dart';

class FarmerProfileTab extends StatefulWidget {
  const FarmerProfileTab({super.key});

  @override
  State<FarmerProfileTab> createState() => _FarmerProfileTabState();
}

class _FarmerProfileTabState extends State<FarmerProfileTab> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseService _dbService = DatabaseService();

  late TextEditingController _farmNameCtrl;
  late TextEditingController _descriptionCtrl;
  late TextEditingController _locationCtrl;
  late TextEditingController _contactCtrl;

  String? _selectedMarketId;
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final farmer = authProvider.currentFarmer;

    _farmNameCtrl = TextEditingController(text: farmer?.farmName ?? '');
    _descriptionCtrl = TextEditingController(text: farmer?.description ?? '');
    _locationCtrl = TextEditingController(text: farmer?.location ?? '');
    _contactCtrl = TextEditingController(text: farmer?.contactNumber ?? '');
    _selectedMarketId = farmer?.marketId;
  }

  @override
  void dispose() {
    _farmNameCtrl.dispose();
    _descriptionCtrl.dispose();
    _locationCtrl.dispose();
    _contactCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile(String farmerId, String userId) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    setState(() => _isLoading = true);

    try {
      await _dbService.updateFarmerProfile(
        farmerId: farmerId,
        farmName: _farmNameCtrl.text.trim(),
        description: _descriptionCtrl.text.trim(),
        location: _locationCtrl.text.trim(),
        contactNumber: _contactCtrl.text.trim(),
        marketId: _selectedMarketId,
      );

      await authProvider.fetchUserData(userId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Farm profile updated successfully'),
            backgroundColor: AppColors.primary,
          ),
        );
        setState(() => _isEditing = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out of your account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.logout();
      if (mounted) {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final farmer = authProvider.currentFarmer;

    if (farmer == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'My Farm Profile',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _isEditing ? Icons.close : Icons.edit_outlined,
              color: AppColors.primary,
            ),
            tooltip: _isEditing ? 'Cancel Edit' : 'Edit Profile',
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
                if (!_isEditing) {
                  _farmNameCtrl.text = farmer.farmName;
                  _descriptionCtrl.text = farmer.description;
                  _locationCtrl.text = farmer.location;
                  _contactCtrl.text = farmer.contactNumber;
                  _selectedMarketId = farmer.marketId;
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.error),
            tooltip: 'Sign Out',
            onPressed: _confirmLogout,
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Profile Header Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.surfaceVariant),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 76,
                      height: 76,
                      decoration: const BoxDecoration(
                        color: AppColors.onTertiaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.storefront,
                        size: 38,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      farmer.farmName.isNotEmpty
                          ? farmer.farmName
                          : 'Local Farm Producer',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.name ?? 'Farmer Account',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: farmer.isApproved
                            ? AppColors.onTertiaryContainer
                            : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            farmer.isApproved
                                ? Icons.verified
                                : Icons.pending_outlined,
                            size: 14,
                            color: farmer.isApproved
                                ? AppColors.primary
                                : AppColors.outline,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            farmer.isApproved
                                ? 'Verified Farm Producer'
                                : 'Pending Verification',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: farmer.isApproved
                                  ? AppColors.primary
                                  : AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Farm Details Section
              const Text(
                'Farm Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.surfaceVariant),
                ),
                child: Column(
                  children: [
                    _buildFormField(
                      label: 'Farm / Business Name',
                      controller: _farmNameCtrl,
                      icon: Icons.business,
                      enabled: _isEditing,
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildFormField(
                      label: 'Farm Location / Address',
                      controller: _locationCtrl,
                      icon: Icons.location_on_outlined,
                      enabled: _isEditing,
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildFormField(
                      label: 'Contact Phone Number',
                      controller: _contactCtrl,
                      icon: Icons.phone_outlined,
                      enabled: _isEditing,
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    // Market Dropdown
                    StreamBuilder<List<MarketModel>>(
                      stream: _dbService.streamMarkets(),
                      builder: (context, mktSnap) {
                        final markets = mktSnap.data ?? [];
                        return DropdownButtonFormField<String>(
                          value: markets.any((m) => m.id == _selectedMarketId)
                              ? _selectedMarketId
                              : null,
                          decoration: InputDecoration(
                            labelText: 'Operating Farmers Market',
                            prefixIcon: const Icon(
                              Icons.storefront_outlined,
                              color: AppColors.outline,
                            ),
                            filled: !_isEditing,
                            fillColor: _isEditing
                                ? AppColors.surface
                                : AppColors.surfaceContainerLow,
                          ),
                          items: markets.map((m) {
                            return DropdownMenuItem(
                              value: m.id,
                              child: Text(m.name, overflow: TextOverflow.ellipsis),
                            );
                          }).toList(),
                          onChanged: _isEditing
                              ? (val) => setState(() => _selectedMarketId = val)
                              : null,
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildFormField(
                      label: 'Farm Description',
                      controller: _descriptionCtrl,
                      icon: Icons.description_outlined,
                      enabled: _isEditing,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Account Details Card
              const Text(
                'Account Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.surfaceVariant),
                ),
                child: Column(
                  children: [
                    _buildReadOnlyRow(
                      Icons.person_outline,
                      'Account Holder',
                      user?.name ?? 'Farmer User',
                    ),
                    const Divider(height: 20, color: AppColors.surfaceVariant),
                    _buildReadOnlyRow(
                      Icons.email_outlined,
                      'Email Address',
                      user?.email ?? 'N/A',
                    ),
                    const Divider(height: 20, color: AppColors.surfaceVariant),
                    _buildReadOnlyRow(
                      Icons.star_outline,
                      'Farmer Rating',
                      '${farmer.rating.toStringAsFixed(1)} / 5.0 (Customer Feedback)',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Save Button (when editing)
              if (_isEditing)
                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () => _saveProfile(farmer.id, user?.uid ?? ''),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Save Profile Changes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              if (!_isEditing) ...[
                OutlinedButton.icon(
                  onPressed: _confirmLogout,
                  icon: const Icon(Icons.logout, size: 18, color: AppColors.error),
                  label: const Text(
                    'Sign Out',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.error,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    side: const BorderSide(color: AppColors.error),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool enabled = true,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.outline),
        filled: !enabled,
        fillColor: enabled ? AppColors.surface : AppColors.surfaceContainerLow,
      ),
      validator: validator,
    );
  }

  Widget _buildReadOnlyRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.outline),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
