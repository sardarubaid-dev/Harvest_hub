import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    bool success = await authProvider.signUpFarmer(
      email: _emailController.text,
      password: _passwordController.text,
      name: _nameController.text,
      farmName: _farmNameController.text,
      description: _descriptionController.text,
      location: _locationController.text,
      contactNumber: _contactController.text,
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
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: "Farm Location / Market Address",
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (val) => val == null || val.trim().isEmpty
                    ? "Location required"
                    : null,
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
                onPressed: authProvider.isLoading
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
                child: authProvider.isLoading
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
