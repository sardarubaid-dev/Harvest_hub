import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';

import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/image_service.dart';
import '../../services/database_service.dart';
import '../../models/farmer_model.dart';

class ApprovalPendingView extends StatefulWidget {
  final FarmerModel farmer;
  const ApprovalPendingView({super.key, required this.farmer});

  @override
  State<ApprovalPendingView> createState() => _ApprovalPendingViewState();
}

class _ApprovalPendingViewState extends State<ApprovalPendingView> with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  final DatabaseService _dbService = DatabaseService();
  
  List<File> _selectedFiles = [];
  bool _isUploading = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _pickDocuments() async {
    final List<XFile> images = await _picker.pickMultiImage(imageQuality: 80);
    if (images.isNotEmpty) {
      setState(() {
        _selectedFiles.addAll(images.map((img) => File(img.path)));
      });
    }
  }

  Future<void> _uploadDocuments() async {
    if (_selectedFiles.isEmpty) return;

    setState(() => _isUploading = true);
    try {
      List<String> newUrls = [];
      for (int i = 0; i < _selectedFiles.length; i++) {
        final url = await ImageService.uploadImage(
          _selectedFiles[i],
          'farmer_doc_${widget.farmer.id}_${DateTime.now().millisecondsSinceEpoch}_$i.jpg',
        );
        if (url != null) newUrls.add(url);
      }

      if (newUrls.isNotEmpty) {
        List<String> combinedDocs = List.from(widget.farmer.verificationDocs)..addAll(newUrls);
        final updatedFarmer = widget.farmer.copyWith(verificationDocs: combinedDocs);
        
        await _dbService.updateFarmer(updatedFarmer);
        
        if (mounted) {
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          await authProvider.fetchUserData(widget.farmer.userId);
          
          setState(() {
            _selectedFiles.clear();
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Documents uploaded successfully!'), backgroundColor: Colors.green),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final bool hasDocs = widget.farmer.verificationDocs.isNotEmpty;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Sign Out',
            onPressed: () async {
              await authProvider.logout();
              if (context.mounted) context.go('/login');
            },
          )
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1E3C2F), Color(0xFF11231A)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // Animated Icon
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: hasDocs ? Colors.blue.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
                      boxShadow: [
                        BoxShadow(
                          color: hasDocs ? Colors.blue.withOpacity(0.5) : Colors.orange.withOpacity(0.5),
                          blurRadius: 30,
                          spreadRadius: 5,
                        )
                      ],
                    ),
                    child: Icon(
                      hasDocs ? Icons.admin_panel_settings : Icons.hourglass_empty,
                      size: 64,
                      color: hasDocs ? Colors.blueAccent : Colors.orangeAccent,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                Text(
                  hasDocs ? 'Documents Under Review' : 'Action Required',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  hasDocs 
                    ? 'Your verification documents have been securely transmitted to the administration team. We will notify you once your farm is verified and approved.'
                    : 'To ensure platform security and quality, we require you to upload exactly 2 verification documents (e.g., 1. ID Card, 2. Farm Photo).',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.7),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Upload Section Glass Card
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (hasDocs) ...[
                            const Text(
                              'Uploaded Documents',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 120,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: widget.farmer.verificationDocs.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    width: 120,
                                    margin: const EdgeInsets.only(right: 12),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      image: DecorationImage(
                                        image: NetworkImage(widget.farmer.verificationDocs[index]),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 24),
                            OutlinedButton.icon(
                              onPressed: null,
                              icon: const Icon(Icons.check_circle, color: Colors.greenAccent),
                              label: const Text('Documents Submitted', style: TextStyle(color: Colors.greenAccent)),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                side: BorderSide(color: Colors.greenAccent.withOpacity(0.5)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                            ),
                          ] else ...[
                            // No Docs uploaded yet
                            if (_selectedFiles.isEmpty)
                              GestureDetector(
                                onTap: _pickDocuments,
                                child: Container(
                                  height: 160,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.orangeAccent.withOpacity(0.5), width: 2, style: BorderStyle.solid),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.upload_file, size: 48, color: Colors.orangeAccent.withOpacity(0.8)),
                                      const SizedBox(height: 12),
                                      const Text('Tap to select 2 documents', style: TextStyle(color: Colors.white70, fontSize: 16)),
                                    ],
                                  ),
                                ),
                              )
                            else ...[
                              SizedBox(
                                height: 120,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _selectedFiles.length,
                                  itemBuilder: (context, index) {
                                    return Stack(
                                      children: [
                                        Container(
                                          width: 120,
                                          margin: const EdgeInsets.only(right: 12, top: 8),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(16),
                                            image: DecorationImage(
                                              image: FileImage(_selectedFiles[index]),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          right: 4,
                                          top: 0,
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _selectedFiles.removeAt(index);
                                              });
                                            },
                                            child: const CircleAvatar(
                                              radius: 14,
                                              backgroundColor: Colors.redAccent,
                                              child: Icon(Icons.close, size: 16, color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: (_isUploading || _selectedFiles.length != 2) ? null : _uploadDocuments,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _selectedFiles.length == 2 ? Colors.orangeAccent : Colors.grey,
                                  foregroundColor: Colors.black87,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  elevation: 8,
                                ),
                                child: _isUploading
                                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.black87, strokeWidth: 3))
                                    : Text(
                                        _selectedFiles.length == 2 ? 'Submit for Verification' : 'Select exactly 2 documents', 
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                                      ),
                              ),
                            ]
                          ]
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 48),
                TextButton.icon(
                  onPressed: () async {
                    await authProvider.fetchUserData(widget.farmer.userId);
                  },
                  icon: const Icon(Icons.refresh, color: Colors.white70),
                  label: const Text('Refresh Status', style: TextStyle(color: Colors.white70)),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
