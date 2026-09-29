import 'package:flutter/material.dart';
import 'package:harvest_hub/models/farmer_model.dart';
import 'package:harvest_hub/theme/app_theme.dart';
import 'package:harvest_hub/services/database_service.dart';
import 'package:intl/intl.dart';

class AdminFarmerDetailScreen extends StatefulWidget {
  final FarmerModel farmer;
  const AdminFarmerDetailScreen({super.key, required this.farmer});

  @override
  State<AdminFarmerDetailScreen> createState() => _AdminFarmerDetailScreenState();
}

class _AdminFarmerDetailScreenState extends State<AdminFarmerDetailScreen> {
  final _dbService = DatabaseService();
  bool _isLoading = false;
  late FarmerModel _farmer;

  @override
  void initState() {
    super.initState();
    _farmer = widget.farmer;
  }

  Future<void> _updateFarmerStatus(bool isApproved, bool isSuspended) async {
    setState(() => _isLoading = true);
    try {
      final updatedFarmer = _farmer.copyWith(
        isApproved: isApproved,
        isSuspended: isSuspended,
      );
      await _dbService.updateFarmer(updatedFarmer);
      setState(() => _farmer = updatedFarmer);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${_farmer.farmName} is now ${isSuspended ? 'Suspended' : (isApproved ? 'Approved' : 'Pending Review')}',
            ),
            backgroundColor: isSuspended ? AppColors.error : AppColors.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating status: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final initials = _farmer.farmName.length >= 2 ? _farmer.farmName.substring(0, 2).toUpperCase() : 'F';
    final createdStr = _farmer.createdAt != null ? DateFormat('MMM d, yyyy - h:mm a').format(_farmer.createdAt!) : 'N/A';
    
    String status = 'Pending Review';
    Color statusColor = Colors.orange;
    if (_farmer.isSuspended) {
      status = 'Suspended';
      statusColor = AppColors.error;
    } else if (_farmer.isApproved) {
      status = 'Verified';
      statusColor = AppColors.primary;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Farmer Details', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 4))],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: AppColors.surfaceVariant,
                          backgroundImage: _farmer.profileImageUrl != null && _farmer.profileImageUrl!.isNotEmpty
                              ? NetworkImage(_farmer.profileImageUrl!)
                              : null,
                          child: _farmer.profileImageUrl == null || _farmer.profileImageUrl!.isEmpty
                              ? Text(initials, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant))
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _farmer.farmName,
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.circle, size: 10, color: statusColor),
                                  const SizedBox(width: 6),
                                  Text(
                                    status,
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: statusColor),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Info Cards
                  _buildSectionHeader(Icons.info_outline, 'Business Information'),
                  _buildInfoCard([
                    _buildInfoRow('Owner Name / Contact', _farmer.contactNumber, Icons.person_outline),
                    const Divider(color: AppColors.surfaceVariant),
                    _buildInfoRow('Location', _farmer.location, Icons.location_on_outlined),
                    const Divider(color: AppColors.surfaceVariant),
                    _buildInfoRow('Registered On', createdStr, Icons.calendar_today_outlined),
                    if (_farmer.description.isNotEmpty) ...[
                      const Divider(color: AppColors.surfaceVariant),
                      _buildInfoRow('Description', _farmer.description, Icons.description_outlined),
                    ],
                  ]),
                  
                  const SizedBox(height: 24),
                  
                  // Verification Docs
                  _buildSectionHeader(Icons.document_scanner_outlined, 'Verification Documents'),
                  const SizedBox(height: 12),
                  if (_farmer.verificationDocs.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.outline),
                      ),
                      child: Column(
                        children: const [
                          Icon(Icons.description_outlined, size: 48, color: AppColors.outline),
                          SizedBox(height: 12),
                          Text('No documents uploaded', style: TextStyle(color: AppColors.onSurfaceVariant)),
                        ],
                      ),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1,
                      ),
                      itemCount: _farmer.verificationDocs.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            _showFullScreenImage(context, _farmer.verificationDocs[index]);
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              _farmer.verificationDocs[index],
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                    
                  const SizedBox(height: 48),
                ],
              ),
            ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))],
          ),
          child: Row(
            children: [
              if (!_farmer.isSuspended)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _updateFarmerStatus(_farmer.isApproved, true),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                    ),
                    child: const Text('Suspend'),
                  ),
                )
              else
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _updateFarmerStatus(_farmer.isApproved, false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      foregroundColor: Colors.orange,
                      side: const BorderSide(color: Colors.orange),
                    ),
                    child: const Text('Unsuspend'),
                  ),
                ),
              const SizedBox(width: 16),
              if (!_farmer.isApproved)
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _updateFarmerStatus(true, false),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Approve Farmer'),
                  ),
                )
              else
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _updateFarmerStatus(false, false),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppColors.surfaceVariant,
                      foregroundColor: AppColors.onSurface,
                    ),
                    child: const Text('Revoke Approval'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onSurface),
        ),
      ],
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.outline),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 14, color: AppColors.onSurface, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Center(
          child: InteractiveViewer(
            child: Image.network(imageUrl),
          ),
        ),
      ),
    ));
  }
}
