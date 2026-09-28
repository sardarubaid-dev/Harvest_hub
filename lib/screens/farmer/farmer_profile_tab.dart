import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../models/market_model.dart';
import '../../models/farmer_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../services/image_service.dart';
import '../../services/location_service.dart';
import '../shared/map_picker_screen.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
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

  File? _newProfileImage;
  double? _latitude;
  double? _longitude;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (image != null) {
      setState(() {
        _newProfileImage = File(image.path);
      });
    }
  }

  Future<void> _getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location services are disabled.')));
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permissions are denied')));
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permissions are permanently denied.')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      String addressStr = "Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)}";
      try {
        Geocoding geocoder = Geocoding();
        List<Placemark> placemarks = await geocoder.placemarkFromCoordinates(position.latitude, position.longitude);
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          List<String> parts = [];
          if (place.street != null && place.street!.isNotEmpty) parts.add(place.street!);
          if (place.subLocality != null && place.subLocality!.isNotEmpty) parts.add(place.subLocality!);
          if (place.locality != null && place.locality!.isNotEmpty) parts.add(place.locality!);
          if (place.country != null && place.country!.isNotEmpty) parts.add(place.country!);
          if (parts.isNotEmpty) addressStr = parts.join(", ");
        }
      } catch (e) {
        // Handle gracefully
      }

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _locationCtrl.text = addressStr;
      });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to get location: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  double _calculateCompleteness(FarmerModel farmer) {
    int total = 5;
    int count = 0;
    if (farmer.farmName.isNotEmpty) count++;
    if (farmer.description.isNotEmpty) count++;
    if (farmer.location.isNotEmpty) count++;
    if (farmer.latitude != null && farmer.longitude != null) count++;
    if (farmer.profileImageUrl != null && farmer.profileImageUrl!.isNotEmpty) count++;
    return count / total;
  }

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
    _latitude = farmer?.latitude;
    _longitude = farmer?.longitude;
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
      String? uploadedImageUrl;
      if (_newProfileImage != null) {
        uploadedImageUrl = await ImageService.uploadImage(
          _newProfileImage!,
          'farmer_profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
      }

      final authProviderForRead = Provider.of<AuthProvider>(context, listen: false);
      final farmerModel = authProviderForRead.currentFarmer;

      await _dbService.updateFarmerProfile(
        farmerId: farmerId,
        farmName: _farmNameCtrl.text.trim(),
        description: _descriptionCtrl.text.trim(),
        location: _locationCtrl.text.trim(),
        contactNumber: _contactCtrl.text.trim(),
        marketId: _selectedMarketId,
        latitude: _latitude,
        longitude: _longitude,
        profileImageUrl: uploadedImageUrl ?? farmerModel?.profileImageUrl,
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
                  _latitude = farmer.latitude;
                  _longitude = farmer.longitude;
                  _newProfileImage = null;
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
          child: Column(
            children: [
              if (farmer != null) ...[
                Builder(
                  builder: (ctx) {
                    final completeness = _calculateCompleteness(farmer);
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      color: AppColors.surfaceContainerLow,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Profile Completeness',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant),
                              ),
                              Text(
                                '${(completeness * 100).toInt()}%',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: completeness == 1.0 ? AppColors.primary : AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: completeness,
                              minHeight: 6,
                              backgroundColor: AppColors.surfaceVariant,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                completeness == 1.0 ? AppColors.primary : Colors.orange,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                ),
              ],
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
              
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.surfaceVariant),
                ),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _isEditing ? _pickImage : null,
                      child: Stack(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppColors.onTertiaryContainer,
                              shape: BoxShape.circle,
                              image: _newProfileImage != null
                                  ? DecorationImage(
                                      image: FileImage(_newProfileImage!),
                                      fit: BoxFit.cover,
                                    )
                                  : (farmer.profileImageUrl != null && farmer.profileImageUrl!.isNotEmpty
                                      ? DecorationImage(
                                          image: NetworkImage(farmer.profileImageUrl!),
                                          fit: BoxFit.cover,
                                        )
                                      : null),
                            ),
                            child: _newProfileImage == null && (farmer.profileImageUrl == null || farmer.profileImageUrl!.isEmpty)
                                ? const Icon(
                                    Icons.storefront,
                                    size: 40,
                                    color: AppColors.primary,
                                  )
                                : null,
                          ),
                          if (_isEditing)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                              ),
                            ),
                        ],
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
                    if (!_isEditing)
                      _buildFormField(
                        label: 'Farm Location / Address',
                        controller: _locationCtrl,
                        icon: Icons.location_on_outlined,
                        enabled: false,
                      )
                    else
                      TypeAheadField<Map<String, dynamic>>(
                        controller: _locationCtrl,
                        builder: (context, controller, focusNode) {
                          return TextFormField(
                            controller: controller,
                            focusNode: focusNode,
                            enabled: _isEditing,
                            decoration: InputDecoration(
                              labelText: 'Farm Location / Address',
                              prefixIcon: const Icon(Icons.location_on_outlined, color: AppColors.outline),
                              suffixIcon: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.my_location, color: AppColors.primary),
                                    tooltip: "Get GPS Location",
                                    onPressed: _getLocation,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.map, color: Colors.blue),
                                    tooltip: "Choose from Map",
                                    onPressed: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => MapPickerScreen(
                                            initialLat: _latitude,
                                            initialLng: _longitude,
                                          ),
                                        ),
                                      );
                                      if (result != null && result is Map<String, dynamic>) {
                                        setState(() {
                                          _latitude = result['latitude'];
                                          _longitude = result['longitude'];
                                          _locationCtrl.text = result['address'] ?? '';
                                        });
                                      }
                                    },
                                  ),
                                ],
                              ),
                              filled: !_isEditing,
                              fillColor: _isEditing ? AppColors.surface : AppColors.surfaceContainerLow,
                            ),
                            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                          );
                        },
                        suggestionsCallback: (pattern) async {
                          return await LocationService.searchPlaces(pattern);
                        },
                        itemBuilder: (context, suggestion) {
                          return ListTile(
                            leading: const Icon(Icons.place),
                            title: Text(
                              suggestion['display_name'] ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        },
                        onSelected: (suggestion) {
                          _locationCtrl.text = suggestion['display_name'] ?? '';
                          _latitude = double.tryParse(suggestion['lat'].toString());
                          _longitude = double.tryParse(suggestion['lon'].toString());
                        },
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
