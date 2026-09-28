import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import '../../providers/auth_provider.dart';
import '../../services/image_service.dart';
import '../../services/location_service.dart';
import '../shared/map_picker_screen.dart';

import '../../providers/auth_provider.dart';

class RegisterFarmerScreen extends StatefulWidget {
  const RegisterFarmerScreen({super.key});

  @override
  State<RegisterFarmerScreen> createState() => _RegisterFarmerScreenState();
}

class _RegisterFarmerScreenState extends State<RegisterFarmerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _farmNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _contactController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLocalLoading = false;
  File? _profileImage;
  double? _latitude;
  double? _longitude;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
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
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permissions are permanently denied, we cannot request permissions.')));
      return;
    }

    setState(() => _isLocalLoading = true);
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
        _locationController.text = addressStr;
      });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to get location: $e')));
    } finally {
      setState(() => _isLocalLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _farmNameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _contactController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleFarmerRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLocalLoading = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    String? profileImageUrl;
    try {
      if (_profileImage != null) {
        profileImageUrl = await ImageService.uploadImage(
          _profileImage!,
          'farmer_profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
      }

      bool success = await authProvider.signUpFarmer(
        email: _emailController.text,
        password: _passwordController.text,
        name: _nameController.text,
        farmName: _farmNameController.text,
        description: _descriptionController.text,
        location: _locationController.text,
        contactNumber: _contactController.text,
        latitude: _latitude,
        longitude: _longitude,
        profileImageUrl: profileImageUrl,
      );

      if (success && mounted) {
        Navigator.pop(context);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? "Registration failed."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLocalLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Farmer Profile Registration"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Register as a Farmer",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Showcase your farm products, update inventory, and receive customer orders",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                    child: _profileImage == null
                        ? const Icon(Icons.add_a_photo, size: 40, color: Colors.grey)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text("Add Profile Photo (Optional)", style: TextStyle(fontSize: 12, color: Colors.grey)),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Owner / Farmer Name",
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? "Name required" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _farmNameController,
                decoration: InputDecoration(
                  labelText: "Farm / Business Name",
                  prefixIcon: const Icon(Icons.store),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (val) => val == null || val.trim().isEmpty
                    ? "Farm name required"
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Email Address",
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (val) => val == null || !val.contains("@")
                    ? "Valid email required"
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contactController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "Contact Phone Number",
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (val) => val == null || val.trim().isEmpty
                    ? "Contact number required"
                    : null,
              ),
              const SizedBox(height: 16),
              TypeAheadField<Map<String, dynamic>>(
                controller: _locationController,
                builder: (context, controller, focusNode) {
                  return TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      labelText: "Farm Location / Market Address",
                      prefixIcon: const Icon(Icons.location_on),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.my_location, color: Colors.green),
                            tooltip: "Get Current Location",
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
                                  _locationController.text = result['address'] ?? '';
                                });
                              }
                            },
                          ),
                        ],
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (val) => val == null || val.trim().isEmpty
                        ? "Location required"
                        : null,
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
                  _locationController.text = suggestion['display_name'] ?? '';
                  _latitude = double.tryParse(suggestion['lat'].toString());
                  _longitude = double.tryParse(suggestion['lon'].toString());
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: "Farm Description",
                  prefixIcon: const Icon(Icons.description),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (val) => val == null || val.length < 6
                    ? "Minimum 6 characters"
                    : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: (authProvider.isLoading || _isLocalLoading)
                    ? null
                    : _handleFarmerRegister,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: (authProvider.isLoading || _isLocalLoading)
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Submit Farmer Registration",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
