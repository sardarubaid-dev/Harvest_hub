import 'package:flutter/material.dart';
import 'package:harvest_hub/theme/app_theme.dart';

import 'package:harvest_hub/services/database_service.dart';
import 'package:harvest_hub/models/farmer_model.dart';
import 'package:intl/intl.dart';

class AdminFarmerManagementTab extends StatefulWidget {
  const AdminFarmerManagementTab({super.key});

  @override
  State<AdminFarmerManagementTab> createState() =>
      _AdminFarmerManagementTabState();
}

class _AdminFarmerManagementTabState extends State<AdminFarmerManagementTab> {
  int _selectedFilterIndex = 0;
  final _dbService = DatabaseService();
  List<FarmerModel> _farmers = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<FarmerModel> _getFilteredFarmers(bool pendingOnly) {
    var filtered = _farmers;
    
    // Apply type filter
    if (pendingOnly) {
      filtered = filtered.where((f) => !f.isApproved).toList();
    } else {
      filtered = filtered.where((f) => f.isApproved).toList();
    }

    // Apply category filter tabs
    if (_selectedFilterIndex == 1) { // Pending
      if (!pendingOnly) return [];
    } else if (_selectedFilterIndex == 2) { // Verified
      if (pendingOnly) return [];
    } else if (_selectedFilterIndex == 3) { // Suspended
      return [];
    }

    // Apply search query
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered.where((f) => 
        f.farmName.toLowerCase().contains(q) || 
        f.contactNumber.toLowerCase().contains(q) || 
        f.location.toLowerCase().contains(q)
      ).toList();
    }
    
    return filtered;
  }

  @override
  void initState() {
    super.initState();
    _dbService.streamAllFarmers().listen((farmers) {
      if (mounted) {
        setState(() {
          _farmers = farmers;
          _isLoading = false;
        });
      }
    });
  }

  List<String> get _filters {
    final pending = _farmers.where((f) => !f.isApproved).length;
    final verified = _farmers.where((f) => f.isApproved).length;
    return ['All (${_farmers.length})', 'Pending Review ($pending)', 'Verified ($verified)', 'Suspended (0)'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Onboard Farmer', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: _isLoading 
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),
                    _buildSearchBar(),
                    const SizedBox(height: 16),
                    _buildFilters(),
                    const SizedBox(height: 24),
                    _buildActionRequiredSection(),
                    const SizedBox(height: 32),
                    _buildRegisteredDirectorySection(),
                    const SizedBox(height: 64), 
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.eco, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'HarvestHub',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'ADMIN',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            const Text(
              'Farmers',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        ),
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {},
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                child: const Text(
                  '3',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
        const CircleAvatar(
          backgroundColor: AppColors.primaryContainer,
          radius: 16,
          child: Icon(Icons.person, color: Colors.white, size: 20),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            onChanged: (val) {
              setState(() {
                _searchQuery = val;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search farmer by name, farm, market sta...',
              prefixIcon: const Icon(Icons.search, color: AppColors.onSurfaceVariant),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFD6DDD6)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFD6DDD6)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.tune, color: AppColors.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = index == _selectedFilterIndex;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedFilterIndex = index;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryContainer : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: Text(
                _filters[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionRequiredSection() {
    final pendingFarmers = _getFilteredFarmers(true);

    if (pendingFarmers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Action Required: ${pendingFarmers.length} Applicants',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.onSurface),
              ),
            ),
            const Text(
              'Priority\nQueue',
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryContainer),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...pendingFarmers.map((f) {
          final initials = f.farmName.length >= 2 ? f.farmName.substring(0, 2).toUpperCase() : 'F';
          final timeStr = DateFormat('MMM d, yyyy').format(f.createdAt ?? DateTime.now());

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildApplicantCard(
              name: f.farmName,
              owner: f.contactNumber,
              location: f.location,
              time: timeStr,
              products: 'Multiple', 
              status: f.isApproved ? 'Verified' : 'Pending',
              isStatusGreen: f.isApproved,
              button1Label: 'Review Docs',
              button1Icon: Icons.visibility_outlined,
              button2Label: 'Approve & Stall',
              button2Icon: Icons.check_circle_outline,
              isButton2Primary: true,
              imageInitials: initials,
              onButton2Pressed: () async {
                await _dbService.updateFarmer(f.copyWith(isApproved: true));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${f.farmName} approved successfully')),
                );
              },
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildApplicantCard({
    required String name,
    required String owner,
    required String location,
    required String time,
    required String products,
    required String status,
    required bool isStatusGreen,
    required String button1Label,
    required IconData button1Icon,
    required String button2Label,
    required IconData button2Icon,
    required bool isButton2Primary,
    required String imageInitials,
    VoidCallback? onButton1Pressed,
    VoidCallback? onButton2Pressed,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(imageInitials, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(12)),
                          child: Text(time, style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$owner • $location',
                      style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFD6E3D6)),
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xFFF0F5F0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.eco_outlined, size: 14, color: AppColors.primaryContainer),
                    const SizedBox(width: 4),
                    Text(products, style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isStatusGreen ? AppColors.secondaryContainer : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isStatusGreen ? Icons.verified_outlined : Icons.assignment_outlined,
                      size: 14,
                      color: isStatusGreen ? AppColors.onSecondaryContainer : AppColors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 11,
                        color: isStatusGreen ? AppColors.onSecondaryContainer : AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onButton1Pressed ?? () {},
                  icon: Icon(button1Icon, size: 18),
                  label: Text(button1Label),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.onSurface,
                    side: const BorderSide(color: Color(0xFFD6DDD6)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    minimumSize: const Size(0, 0),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: isButton2Primary
                    ? ElevatedButton.icon(
                        onPressed: onButton2Pressed ?? () {},
                        icon: Icon(button2Icon, size: 18, color: Colors.white),
                        label: Text(button2Label),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          minimumSize: const Size(0, 0),
                        ),
                      )
                    : OutlinedButton.icon(
                        onPressed: onButton2Pressed ?? () {},
                        icon: Icon(button2Icon, size: 18),
                        label: Text(button2Label),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.onSurface,
                          side: const BorderSide(color: Color(0xFFD6DDD6)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          minimumSize: const Size(0, 0),
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRegisteredDirectorySection() {
    final verifiedFarmers = _getFilteredFarmers(false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Registered Directory',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.onSurface),
            ),
            Text(
              '${verifiedFarmers.length} Verified Active',
              style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (verifiedFarmers.isEmpty)
          const Text('No verified farmers found.', style: TextStyle(color: AppColors.onSurfaceVariant)),
        ...verifiedFarmers.map((f) {
          final initials = f.farmName.length >= 2 ? f.farmName.substring(0, 2).toUpperCase() : 'F';
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildDirectoryCard(
              name: f.farmName,
              owner: f.contactNumber,
              location: f.location,
              rating: f.rating.toStringAsFixed(1),
              reviews: '(0)',
              productsCount: 'Products Active',
              revenue: 'Rs. 0/mo',
              status: 'Active & Selling',
              stall: 'Stall',
              isStatusGreen: true,
              initials: initials,
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildDirectoryCard({
    required String name,
    required String owner,
    required String location,
    required String rating,
    required String reviews,
    required String productsCount,
    required String revenue,
    required String status,
    required String stall,
    required bool isStatusGreen,
    required String initials,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(initials, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          name,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.verified, size: 14, color: AppColors.primaryContainer),
                        const Spacer(),
                        const Icon(Icons.more_vert, size: 20, color: AppColors.onSurfaceVariant),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$owner • $location',
                      style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 4,
            runSpacing: 4,
            children: [
              const Icon(Icons.star_border, size: 16, color: AppColors.primaryContainer),
              Text(
                rating,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.onSurface),
              ),
              Text(
                reviews,
                style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Text('|', style: TextStyle(color: AppColors.surfaceVariant)),
              ),
              Text(
                productsCount,
                style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(width: 8),
              Text(
                revenue,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.onSurface),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isStatusGreen ? AppColors.secondaryContainer : AppColors.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.circle,
                      size: 8,
                      color: isStatusGreen ? AppColors.onSecondaryContainer : AppColors.error,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 11,
                        color: isStatusGreen ? AppColors.onSecondaryContainer : AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.storefront_outlined, size: 14, color: AppColors.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    stall,
                    style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
