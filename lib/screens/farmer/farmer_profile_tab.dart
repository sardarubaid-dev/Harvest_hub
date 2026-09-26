import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:harvest_hub/theme/app_theme.dart';
import 'package:harvest_hub/providers/auth_provider.dart';
import 'package:harvest_hub/services/database_service.dart';

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
  }

  @override
  void dispose() {
    _farmNameCtrl.dispose();
    _descriptionCtrl.dispose();
    _locationCtrl.dispose();
    _contactCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile(String farmerId) async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        await _dbService.updateFarmerProfile(
          farmerId: farmerId,
          farmName: _farmNameCtrl.text,
          description: _descriptionCtrl.text,
          location: _locationCtrl.text,
          contactNumber: _contactCtrl.text,
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully'), backgroundColor: AppColors.primary),
        );
        setState(() => _isEditing = false);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e'), backgroundColor: AppColors.error),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final farmer = authProvider.currentFarmer;

    if (farmer == null) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit, color: AppColors.primary),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
                if (!_isEditing) {
                  // Reset fields
                  _farmNameCtrl.text = farmer.farmName;
                  _descriptionCtrl.text = farmer.description;
                  _locationCtrl.text = farmer.location;
                  _contactCtrl.text = farmer.contactNumber;
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.error),
            onPressed: () => authProvider.logout(),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.primaryContainer,
                  child: Icon(Icons.storefront, size: 48, color: Colors.white),
                ),
                const SizedBox(height: 16),
                Text(
                  farmer.farmName.isNotEmpty ? farmer.farmName : 'No Farm Name',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  farmer.isApproved ? 'Verified Farmer' : 'Pending Verification',
                  style: TextStyle(
                    color: farmer.isApproved ? AppColors.primary : AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),
                
                _buildTextField('Farm Name', _farmNameCtrl, Icons.business, enabled: _isEditing),
                const SizedBox(height: 16),
                _buildTextField('Location', _locationCtrl, Icons.location_on, enabled: _isEditing),
                const SizedBox(height: 16),
                _buildTextField('Contact Number', _contactCtrl, Icons.phone, enabled: _isEditing),
                const SizedBox(height: 16),
                _buildTextField('Description', _descriptionCtrl, Icons.description, enabled: _isEditing, maxLines: 3),
                
                const SizedBox(height: 32),
                if (_isEditing)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : () => _saveProfile(farmer.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isLoading 
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {bool enabled = true, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: enabled ? AppColors.primary : AppColors.outline),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.surfaceVariant),
        ),
        filled: !enabled,
        fillColor: AppColors.surfaceVariant,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'This field cannot be empty';
        }
        return null;
      },
    );
  }
}
