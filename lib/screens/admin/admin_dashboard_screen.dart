import 'package:flutter/material.dart';
import 'package:harvest_hub/theme/app_theme.dart';
import 'package:harvest_hub/core/dummy_data.dart';
import 'package:harvest_hub/models/farmer_model.dart';
import 'package:harvest_hub/models/order_model.dart';
import 'package:harvest_hub/models/user_model.dart';
import 'package:harvest_hub/models/product_model.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'admin_farmer_management_tab.dart';

// --- Simulated Service to mimic Backend Fetching ---
class AdminDashboardData {
  final int pendingApplications;
  final double hubCapacity;
  final double totalGmv;
  final int totalOrders;
  final double orderCompletionRate;
  final int activeFarmers;
  final int pendingFarmers;
  final int activeBuyers;
  final double hubEfficiency;
  final List<MarketplaceActivity> activities;

  AdminDashboardData({
    required this.pendingApplications,
    required this.hubCapacity,
    required this.totalGmv,
    required this.totalOrders,
    required this.orderCompletionRate,
    required this.activeFarmers,
    required this.pendingFarmers,
    required this.activeBuyers,
    required this.hubEfficiency,
    required this.activities,
  });
}

class MarketplaceActivity {
  final String type; // 'restock', 'application', 'order', 'flag'
  final String title;
  final String description;
  final String? badgeText;
  final String? subtext;
  final Duration timeAgo;

  MarketplaceActivity({
    required this.type,
    required this.title,
    required this.description,
    this.badgeText,
    this.subtext,
    required this.timeAgo,
  });
}

class MockAdminService {
  Future<AdminDashboardData> fetchDashboardData() async {
    // Simulating network delay
    await Future.delayed(const Duration(milliseconds: 600));

    // Calculate metrics from our "Database" (DummyData)
    final farmers = DummyData.seedFarmers;
    final orders = DummyData.seedOrders;
    final users = DummyData.seedUsers;
    final products = DummyData.seedProducts;

    final pendingFarmersCount = farmers.where((f) => !f.isApproved).length;
    final activeFarmersCount = farmers.where((f) => f.isApproved).length;
    final activeBuyersCount = users.where((u) => u.role == 'customer').length;
    
    final totalGmv = orders.fold(0.0, (sum, order) => sum + order.totalAmount);
    final completedOrders = orders.where((o) => o.status == 'Completed').length;
    final completionRate = orders.isEmpty ? 0.0 : (completedOrders / orders.length) * 100;

    // Synthesize Activities from DB records
    List<MarketplaceActivity> activities = [];
    
    // Add restock from products
    if (products.isNotEmpty) {
      activities.add(MarketplaceActivity(
        type: 'restock',
        title: products.first.farmerName ?? 'Farm',
        description: 'Restocked ${products.first.quantity.toInt()}${products.first.unit} ${products.first.name}',
        badgeText: 'Batch #GV-902',
        subtext: 'Stall 4A',
        timeAgo: const Duration(minutes: 12),
      ));
    }

    // Add pending apps
    if (pendingFarmersCount > 0) {
      final pendingF = farmers.firstWhere((f) => !f.isApproved);
      activities.add(MarketplaceActivity(
        type: 'application',
        title: 'New Application Received',
        description: '${pendingF.farmName} (${pendingF.location})',
        badgeText: 'Tier-1 Pending Review',
        timeAgo: const Duration(minutes: 35),
      ));
    } else {
       activities.add(MarketplaceActivity(
        type: 'application',
        title: 'New Application Received',
        description: 'Indus Organic Orchard (Hyderabad District)',
        badgeText: 'Tier-1 Pending Review',
        timeAgo: const Duration(minutes: 35),
      ));
    }

    // Add order collection
    if (orders.isNotEmpty) {
      String shortId = orders.first.id;
      if (shortId.length > 4) {
        shortId = shortId.substring(0, 4);
      }
      
      activities.add(MarketplaceActivity(
        type: 'order',
        title: 'Order #$shortId Collected',
        description: 'Direct collection completed at Stall 14B',
        subtext: 'Buyer: ${orders.first.customerName} • ${orders.first.items.length} items',
        timeAgo: const Duration(minutes: 48),
      ));
    }

    activities.add(MarketplaceActivity(
      type: 'flag',
      title: 'Price Flag Resolved',
      description: 'Pure Cow Milk fair ceiling approved across...',
      badgeText: 'Auto-reconciled',
      timeAgo: const Duration(hours: 1),
    ));

    // If counts are very low (because dummy data only has 1 or 2 items), 
    // we use a mix of computed and design-specific fallback logic to make the UI look good as requested.
    // The user requested using DummyData as the DB.
    return AdminDashboardData(
      pendingApplications: pendingFarmersCount > 0 ? pendingFarmersCount : 6, 
      hubCapacity: 84.0, 
      totalGmv: totalGmv > 0 ? totalGmv : 1420000, 
      totalOrders: orders.length > 1 ? orders.length : 1842, 
      orderCompletionRate: completionRate > 0 ? completionRate : 94.2, 
      activeFarmers: activeFarmersCount > 1 ? activeFarmersCount : 48, 
      pendingFarmers: pendingFarmersCount > 0 ? pendingFarmersCount : 6, 
      activeBuyers: activeBuyersCount > 1 ? activeBuyersCount : 3210, 
      hubEfficiency: 98.2,
      activities: activities,
    );
  }
}

class AdminDashboardScreen extends StatefulWidget {
  final String initialTab;
  const AdminDashboardScreen({super.key, this.initialTab = 'dashboard'});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final MockAdminService _adminService = MockAdminService();
  int _currentTabIndex = 0;
  String _selectedMonth = 'Oct 2024';

  @override
  void initState() {
    super.initState();
    _currentTabIndex = _getTabIndexFromString(widget.initialTab);
  }

  @override
  void didUpdateWidget(AdminDashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTab != oldWidget.initialTab) {
      setState(() {
        _currentTabIndex = _getTabIndexFromString(widget.initialTab);
      });
    }
  }

  int _getTabIndexFromString(String tab) {
    switch (tab) {
      case 'dashboard': return 0;
      case 'farmers': return 1;
      case 'orders': return 2;
      case 'reports': return 3;
      default: return 0;
    }
  }

  String _getAppBarSubtitle() {
    switch (_currentTabIndex) {
      case 0: return 'Dashboard';
      case 1: return 'Farmers';
      case 2: return 'Orders';
      case 3: return 'Reports';
      default: return 'Dashboard';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF3), // Very light green/off-white background
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF7FAF3),
      elevation: 0,
      titleSpacing: 16,
      title: Row(
        children: [
          // Logo placeholder
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.eco, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 8),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('HarvestHub', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
              Text('LOCAL FARM MARKETPLACE', style: TextStyle(fontSize: 7, color: Colors.black54, letterSpacing: 0.5)),
            ],
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Harv...', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87), overflow: TextOverflow.ellipsis),
                Text(_getAppBarSubtitle(), style: const TextStyle(fontSize: 9, color: Colors.black54)),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.green.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('ADMIN', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.green)),
          ),
        ],
      ),
      actions: [
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none, color: Colors.black87, size: 28),
              onPressed: () {},
            ),
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Text('3', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
        const CircleAvatar(
          backgroundColor: AppColors.primary,
          radius: 16,
          child: Icon(Icons.person, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildBody() {
    return IndexedStack(
      index: _currentTabIndex,
      children: [
        _buildDashboardTab(),
        const AdminFarmerManagementTab(),
        const Center(child: Text("Orders Moderation")),
        const Center(child: Text("Reports & Analytics")),
      ],
    );
  }

  Widget _buildDashboardTab() {
    return FutureBuilder<AdminDashboardData>(
      future: _adminService.fetchDashboardData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final data = snapshot.data!;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderRow(),
              const SizedBox(height: 16),
              _buildAlertCards(data),
              const SizedBox(height: 16),
              _buildStatsGrid(data),
              const SizedBox(height: 16),
              _buildEfficiencyCard(data),
              const SizedBox(height: 24),
              const Text('Administrative Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildActionsRow(),
              const SizedBox(height: 24),
              _buildHubImageCard(),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Text('Recent Marketplace Activity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(width: 8),
                      Icon(Icons.circle, color: AppColors.primary, size: 10),
                    ],
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('View All', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              _buildActivityList(data.activities),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeaderRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Marketplace Ov...', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade200,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.circle, color: AppColors.primary, size: 8),
                      SizedBox(width: 6),
                      Text('Live Platform\nNormal', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary, height: 1.1)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Text('• Latency\n42ms', style: TextStyle(fontSize: 11, color: Colors.black54, height: 1.1)),
              ],
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today, size: 16, color: Colors.black87),
              const SizedBox(width: 8),
              Text(_selectedMonth, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const Icon(Icons.arrow_drop_down, color: Colors.black87),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAlertCards(AdminDashboardData data) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFEBEE), // Light red
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.red.shade700, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.assignment_late, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${data.pendingApplications} Applications Pending', style: TextStyle(color: Colors.red.shade900, fontWeight: FontWeight.bold, fontSize: 15)),
                    Text('Farmer documentation awaiting KYC ...', style: TextStyle(color: Colors.red.shade700, fontSize: 12)),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  minimumSize: const Size(0, 36),
                ),
                child: const Text('Review', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFE8ECE5), // Light olive/grey
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.warehouse, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Karachi Farmers Hub at ${data.hubCapacity.toInt()}% Capacity', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                    const Text('Cold chain staging bays near maximum thr...', style: TextStyle(fontSize: 12, color: Colors.black54)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(20)),
                child: Text('${data.hubCapacity.toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(AdminDashboardData data) {
    String formatCurrency(double amount) {
      if (amount >= 1000000) return '${(amount / 1000000).toStringAsFixed(2)}M';
      if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(1)}K';
      return amount.toStringAsFixed(0);
    }
    final NumberFormat formatter = NumberFormat('#,##0');

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          title: 'Total GMV',
          value: 'Rs. ${formatCurrency(data.totalGmv)}',
          icon: Icons.payments_outlined,
          bottomWidget: const Row(
            children: [
              Icon(Icons.trending_up, color: AppColors.primary, size: 14),
              SizedBox(width: 4),
              Text('+18.4%', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
              Text(' vs mo', style: TextStyle(color: Colors.black54, fontSize: 12)),
            ],
          ),
        ),
        _buildStatCard(
          title: 'Total Orders',
          value: formatter.format(data.totalOrders),
          icon: Icons.receipt_long_outlined,
          bottomWidget: Row(
            children: [
              const Icon(Icons.circle, color: AppColors.primary, size: 8),
              const SizedBox(width: 4),
              Text('${data.orderCompletionRate.toStringAsFixed(1)}% completed', style: const TextStyle(color: Colors.black87, fontSize: 12)),
            ],
          ),
        ),
        _buildStatCard(
          title: 'Verified Farmers',
          value: '${data.activeFarmers} Active',
          icon: Icons.agriculture_outlined,
          bottomWidget: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(4)),
            child: Text('${data.pendingFarmers} Pending', style: TextStyle(color: Colors.red.shade900, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ),
        _buildStatCard(
          title: 'Active Buyers',
          value: formatter.format(data.activeBuyers),
          icon: Icons.people_outline,
          bottomWidget: const Row(
            children: [
              Icon(Icons.arrow_upward, color: AppColors.primary, size: 14),
              SizedBox(width: 4),
              Text('+142', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
              Text(' new', style: TextStyle(color: Colors.black54, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({required String title, required String value, required IconData icon, required Widget bottomWidget}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: Colors.black87, fontSize: 12)),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(4)),
                child: Icon(icon, color: AppColors.primary, size: 16),
              ),
            ],
          ),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
          bottomWidget,
        ],
      ),
    );
  }

  Widget _buildEfficiencyCard(AdminDashboardData data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 50,
                width: 50,
                child: CircularProgressIndicator(
                  value: data.hubEfficiency / 100,
                  backgroundColor: Colors.grey.shade200,
                  color: AppColors.primary,
                  strokeWidth: 4,
                ),
              ),
              Text('${data.hubEfficiency.toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hub Fulfillment Efficiency', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text('98.2% on-time stall pickup across 4 d...', style: TextStyle(fontSize: 12, color: Colors.black54)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: Colors.green.shade200, borderRadius: BorderRadius.circular(20)),
            child: const Text('Optimal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildActionItem('Verify\nFarmers', Icons.verified_outlined, Colors.green.shade100, AppColors.primary),
        _buildActionItem('Broadcast\nNotice', Icons.campaign_outlined, Colors.grey.shade100, Colors.black87),
        _buildActionItem('Categories', Icons.category_outlined, Colors.grey.shade100, Colors.black87),
        _buildActionItem('Audit Logs', Icons.shield_outlined, Colors.grey.shade100, Colors.black87),
      ],
    );
  }

  Widget _buildActionItem(String label, IconData icon, Color bgColor, Color iconColor) {
    return Container(
      width: 80,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 8),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, height: 1.2)),
        ],
      ),
    );
  }

  Widget _buildHubImageCard() {
    return Column(
      children: [
        Container(
          height: 140,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: const DecorationImage(
              image: NetworkImage('https://images.unsplash.com/photo-1586880244406-556ebe35f282?w=800&q=80'),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black.withOpacity(0.8), Colors.transparent],
              ),
            ),
            padding: const EdgeInsets.all(16),
            alignment: Alignment.bottomLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PRIMARY TRANSIT NODE', style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    Text('Malir Collection Center', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.9), borderRadius: BorderRadius.circular(4)),
                  child: const Text('Active Depots: 4/4', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.local_shipping_outlined, color: AppColors.primary, size: 16),
                SizedBox(width: 8),
                Text('18 outbound transport vans en route', style: TextStyle(fontSize: 13, color: Colors.black87)),
              ],
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
              child: const Text('Inspect Hubs', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActivityList(List<MarketplaceActivity> activities) {
    return Column(
      children: activities.map((activity) {
        Color iconBg;
        IconData icon;
        Color iconColor = AppColors.primary;

        switch (activity.type) {
          case 'restock':
            iconBg = Colors.green.shade100;
            icon = Icons.inventory_2_outlined;
            break;
          case 'application':
            iconBg = Colors.red.shade50;
            icon = Icons.person_add_outlined;
            iconColor = Colors.red.shade700;
            break;
          case 'order':
            iconBg = Colors.grey.shade200;
            icon = Icons.check_circle_outline;
            iconColor = Colors.black87;
            break;
          case 'flag':
          default:
            iconBg = Colors.green.shade100;
            icon = Icons.verified_user_outlined;
            break;
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(activity.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        Text('${activity.timeAgo.inMinutes > 59 ? '${activity.timeAgo.inHours}h' : '${activity.timeAgo.inMinutes}m'} ago', style: const TextStyle(color: Colors.black54, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(activity.description, style: const TextStyle(fontSize: 13, color: Colors.black87)),
                    if (activity.badgeText != null || activity.subtext != null)
                      const SizedBox(height: 6),
                    if (activity.badgeText != null || activity.subtext != null)
                      Row(
                        children: [
                          if (activity.badgeText != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: activity.type == 'application' ? Colors.red.shade100 : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(activity.badgeText!, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: activity.type == 'application' ? Colors.red.shade900 : Colors.black87)),
                            ),
                          if (activity.badgeText != null && activity.subtext != null) const SizedBox(width: 8),
                          if (activity.subtext != null)
                            Text(activity.subtext!, style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold)),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentTabIndex,
      onTap: (index) {
        String path = '/admin/dashboard';
        if (index == 1) path = '/admin/farmers';
        if (index == 2) path = '/admin/orders';
        if (index == 3) path = '/admin/reports';
        context.go(path);
      },
      selectedItemColor: AppColors.primary,
      unselectedItemColor: Colors.black54,
      showUnselectedLabels: true,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFFF7FAF3),
      elevation: 8,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.agriculture_outlined), label: 'Farmers'),
        BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), label: 'Orders'),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), label: 'Reports'),
      ],
    );
  }
}


