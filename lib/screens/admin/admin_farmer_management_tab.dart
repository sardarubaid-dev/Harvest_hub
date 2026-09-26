import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class AdminFarmerManagementTab extends StatefulWidget {
  const AdminFarmerManagementTab({super.key});

  @override
  State<AdminFarmerManagementTab> createState() => _AdminFarmerManagementTabState();
}

class _AdminFarmerManagementTabState extends State<AdminFarmerManagementTab> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = ['All (48)', 'Pending Review (6)', 'Verified (38)', 'Suspended'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF3),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSearchBar(),
                const SizedBox(height: 16),
                _buildFilterChips(),
                const SizedBox(height: 24),
                _buildSectionHeader('Action Required: 6 Applicants', 'Priority Queue', showRedDot: true),
                const SizedBox(height: 16),
                _buildActionRequiredCard(
                  name: 'Indus Valley O...',
                  details: 'Tariq Alvi • Mirpur Khas',
                  timeAgo: 'Today, 9:30 AM',
                  imagePath: 'https://images.unsplash.com/photo-1595842526569-8d77f1cf34f3?w=200&q=80',
                  tags: [
                    {'text': 'Mangoes, Guavas, Citrus', 'icon': Icons.eco_outlined, 'type': 'outline'},
                    {'text': 'CNIC & Land Deed Verified', 'icon': Icons.verified_outlined, 'type': 'filled_green'},
                  ],
                  primaryAction: 'Approve & Stall',
                  secondaryAction: 'Review Docs',
                ),
                const SizedBox(height: 16),
                _buildActionRequiredCard(
                  name: 'Sindh Bio-Greens',
                  details: 'Ayesha Baloch • Thatta',
                  timeAgo: 'Yesterday',
                  imagePath: 'https://images.unsplash.com/photo-1544717305-2782549b5136?w=200&q=80',
                  tags: [
                    {'text': 'Spinach, Kale, Mint', 'icon': Icons.eco_outlined, 'type': 'outline'},
                    {'text': 'Soil Organic Cert Pending', 'icon': Icons.pending_actions, 'type': 'filled_grey'},
                  ],
                  primaryAction: 'View Details',
                  secondaryAction: 'Request Info',
                  greyActions: true,
                ),
                const SizedBox(height: 24),
                _buildSectionHeader('Registered Directory', '38 Verified Active', isDarkRightText: true),
                const SizedBox(height: 16),
                _buildVerifiedFarmerCard(
                  name: 'Green Valley Farm',
                  details: 'Tariq Mehmood • Stall 14B, Karach...',
                  rating: '4.8',
                  reviews: '(120)',
                  products: '24 Active Products',
                  revenue: 'Rs. 142k/mo',
                  imagePath: 'https://images.unsplash.com/photo-1605000797499-95a51c5269ae?w=200&q=80',
                  statusTag: 'Active & Selling',
                  statusColor: Colors.green,
                  stallTag: 'Stall 14B',
                ),
                const SizedBox(height: 16),
                _buildVerifiedFarmerCard(
                  name: 'Indus Organic Fields',
                  details: 'Rashid Khan • Stall 8A',
                  rating: '4.9',
                  reviews: '(84)',
                  products: '16 Active Products',
                  revenue: 'Rs. 98k/mo',
                  imagePath: 'https://images.unsplash.com/photo-1592688755601-3c588e734cf8?w=200&q=80',
                  statusTag: 'Active',
                  statusColor: Colors.green,
                  stallTag: 'Stall 8A',
                ),
                const SizedBox(height: 16),
                _buildVerifiedFarmerCard(
                  name: 'Meadow Dairy Farm',
                  details: 'Zubair Ahmed • Stall 3C',
                  rating: '4.7',
                  reviews: '(62)',
                  products: '8 Dairy Products',
                  revenue: 'Rs. 210k/mo',
                  imagePath: 'https://images.unsplash.com/photo-1527847263472-aa5338d17f6f?w=200&q=80',
                  statusTag: 'Low Stock Alert',
                  statusColor: Colors.red,
                  stallTag: 'Stall 3C',
                ),
                const SizedBox(height: 80), // Space for FAB
              ],
            ),
          ),
          
          // Floating Action Button
          Positioned(
            bottom: 24,
            right: 16,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Onboard Farmer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Icon(Icons.search, color: Colors.grey.shade500),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Search farmer by name, farm, market sta',
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.tune, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filters.asMap().entries.map((entry) {
          int idx = entry.key;
          String label = entry.value;
          bool isSelected = _selectedFilterIndex == idx;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () => setState(() => _selectedFilterIndex = idx),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, {bool showRedDot = false, bool isDarkRightText = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showRedDot)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, right: 8.0),
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.red.shade700,
                shape: BoxShape.circle,
              ),
            ),
          ),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.2),
          ),
        ),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isDarkRightText ? FontWeight.normal : FontWeight.bold,
            color: isDarkRightText ? Colors.black87 : AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildActionRequiredCard({
    required String name,
    required String details,
    required String timeAgo,
    required String imagePath,
    required List<Map<String, dynamic>> tags,
    required String primaryAction,
    required String secondaryAction,
    bool greyActions = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(imagePath, width: 48, height: 48, fit: BoxFit.cover),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(details, style: const TextStyle(fontSize: 13, color: Colors.black87)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(timeAgo, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags.map((tag) {
              Color bgColor;
              Color textColor;
              Color borderColor;
              
              if (tag['type'] == 'outline') {
                bgColor = Colors.green.shade50;
                textColor = Colors.black87;
                borderColor = Colors.transparent;
              } else if (tag['type'] == 'filled_green') {
                bgColor = Colors.green.shade300;
                textColor = Colors.black87;
                borderColor = Colors.transparent;
              } else {
                bgColor = Colors.grey.shade200;
                textColor = Colors.black87;
                borderColor = Colors.transparent;
              }

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(tag['icon'], size: 14, color: textColor),
                    const SizedBox(width: 6),
                    Text(tag['text'], style: TextStyle(fontSize: 12, color: textColor, fontWeight: FontWeight.w500)),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: Icon(greyActions ? Icons.info_outline : Icons.visibility_outlined, size: 18, color: Colors.black87),
                  label: Text(secondaryAction, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: greyActions ? Colors.grey.shade200 : Colors.white,
                    side: BorderSide(color: greyActions ? Colors.transparent : Colors.grey.shade300),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: Icon(greyActions ? Icons.description_outlined : Icons.check_circle_outline, size: 18, color: greyActions ? Colors.black87 : Colors.white),
                  label: Text(primaryAction, style: TextStyle(color: greyActions ? Colors.black87 : Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: greyActions ? Colors.grey.shade200 : AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVerifiedFarmerCard({
    required String name,
    required String details,
    required String rating,
    required String reviews,
    required String products,
    required String revenue,
    required String imagePath,
    required String statusTag,
    required Color statusColor,
    required String stallTag,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(imagePath, width: 48, height: 48, fit: BoxFit.cover),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 4),
                        const Icon(Icons.verified_outlined, color: Colors.green, size: 16),
                      ],
                    ),
                    Text(details, style: const TextStyle(fontSize: 13, color: Colors.black87)),
                  ],
                ),
              ),
              const Icon(Icons.more_vert, color: Colors.black54),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.star_border, color: Colors.green, size: 16),
              const SizedBox(width: 4),
              Text(rating, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(width: 4),
              Text(reviews, style: const TextStyle(color: Colors.black54, fontSize: 13)),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text('|', style: TextStyle(color: Colors.black26)),
              ),
              Text(products, style: const TextStyle(fontSize: 13, color: Colors.black87)),
              const Spacer(),
              Text(revenue, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.circle, color: statusColor, size: 8),
                    const SizedBox(width: 6),
                    Text(statusTag, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor.withOpacity(1.0))),
                  ],
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.storefront_outlined, size: 14, color: Colors.black54),
                  const SizedBox(width: 4),
                  Text(stallTag, style: const TextStyle(color: Colors.black54, fontSize: 13)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
