import 'package:flutter/material.dart';
import 'package:harvest_hub/theme/app_theme.dart';
import 'package:harvest_hub/core/dummy_data.dart';

// --- Mock Data Service for Dashboard ---
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
  final String timeAgo;

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
    await Future.delayed(const Duration(milliseconds: 600));

    return AdminDashboardData(
      pendingApplications: 6,
      hubCapacity: 84.0,
      totalGmv: 1420000,
      totalOrders: 1842,
      orderCompletionRate: 94.2,
      activeFarmers: 48,
      pendingFarmers: 6,
      activeBuyers: 3210,
      hubEfficiency: 98.2,
      activities: [
        MarketplaceActivity(
          type: 'restock',
          title: 'Green Valley Farm',
          description: 'Restocked 50kg Organic Tomatoes',
          badgeText: 'Batch #GV-902',
          subtext: 'Stall 4A',
          timeAgo: '12m ago',
        ),
        MarketplaceActivity(
          type: 'application',
          title: 'New Application Received',
          description: 'Indus Organic Orchard (Hyderabad District)',
          badgeText: 'Tier-1 Pending Review',
          timeAgo: '35m ago',
        ),
        MarketplaceActivity(
          type: 'order',
          title: 'Order #HH10248 Collected',
          description: 'Direct collection completed at Stall 14B',
          subtext: 'Buyer: S. Tariq • 4 items',
          timeAgo: '48m ago',
        ),
        MarketplaceActivity(
          type: 'flag',
          title: 'Price Flag Resolved',
          description: 'Pure Cow Milk fair ceiling approved across...',
          badgeText: 'Auto-reconciled',
          timeAgo: '1h ago',
        ),
      ],
    );
  }
}

class AdminDashboardTab extends StatefulWidget {
  const AdminDashboardTab({super.key});

  @override
  State<AdminDashboardTab> createState() => _AdminDashboardTabState();
}

class _AdminDashboardTabState extends State<AdminDashboardTab> {
  final MockAdminService _adminService = MockAdminService();
  AdminDashboardData? _data;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await _adminService.fetchDashboardData();
    if (mounted) {
      setState(() {
        _data = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
                    _buildOverviewHeader(),
                    const SizedBox(height: 16),
                    _buildAlerts(),
                    const SizedBox(height: 16),
                    _buildMetricsGrid(),
                    const SizedBox(height: 16),
                    _buildEfficiencyCard(),
                    const SizedBox(height: 24),
                    _buildAdministrativeActions(),
                    const SizedBox(height: 24),
                    _buildHubBanner(),
                    const SizedBox(height: 24),
                    _buildRecentActivity(),
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
            Text(
              'Dashboard',
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

  Widget _buildOverviewHeader() {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 16,
      runSpacing: 16,
      children: [
        Container(
          constraints: const BoxConstraints(maxWidth: 240),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Marketplace Overview',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Live Platform Normal',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSecondaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '• Latency 42ms',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: const [
              Icon(Icons.calendar_today, size: 16),
              SizedBox(width: 8),
              Text('Oct 2024', style: TextStyle(fontWeight: FontWeight.w600)),
              SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down, size: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAlerts() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.errorContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.assignment_late, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_data!.pendingApplications} Applications Pending',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.error,
                      ),
                    ),
                    const Text(
                      'Farmer documentation awaiting KYC...',
                      style: TextStyle(fontSize: 13, color: AppColors.error),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(80, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: const Text('Review'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFE8EFE8), // Light greenish gray
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.warehouse, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Karachi Farmers Hub at 84% Capacity',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                    ),
                    Text(
                      'Cold chain staging bays near maximum thr...',
                      style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFD6E3D6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  '84%',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.4,
      children: [
        _buildMetricCard(
          title: 'Total GMV',
          value: 'Rs. 1.42M',
          subtitle: '+18.4% vs mo',
          icon: Icons.payments_outlined,
          isPositive: true,
        ),
        _buildMetricCard(
          title: 'Total Orders',
          value: '1,842',
          subtitle: '94.2% completed',
          icon: Icons.receipt_outlined,
          isPositive: true,
        ),
        _buildMetricCard(
          title: 'Verified Farmers',
          value: '48 Active',
          subtitleBadge: '6 Pending',
          icon: Icons.agriculture_outlined,
          isPositive: true,
        ),
        _buildMetricCard(
          title: 'Active Buyers',
          value: '3,210',
          subtitle: '+142 new',
          icon: Icons.people_outline,
          isPositive: true,
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    String? subtitle,
    String? subtitleBadge,
    required IconData icon,
    required bool isPositive,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 16, color: AppColors.primaryContainer),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
          if (subtitle != null)
            Row(
              children: [
                if (subtitle.contains('+'))
                  const Icon(Icons.trending_up, size: 14, color: AppColors.primaryContainer)
                else if (subtitle.contains('completed'))
                  const Icon(Icons.circle, size: 10, color: AppColors.primaryContainer),
                const SizedBox(width: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          if (subtitleBadge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.errorContainer,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                subtitleBadge,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.error,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEfficiencyCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(
                  value: 0.98,
                  strokeWidth: 5,
                  backgroundColor: AppColors.surfaceVariant,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryContainer),
                ),
              ),
              const Text(
                '98%',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Hub Fulfillment Efficiency',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Text(
                  '98.2% on-time stall pickup across 4 d...',
                  style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'Optimal',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.onSecondaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdministrativeActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'Administrative Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
            Text(
              'Operations',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.spaceBetween,
          children: [
            _buildActionButton(Icons.verified_user_outlined, 'Verify\nFarmers', AppColors.secondaryContainer),
            _buildActionButton(Icons.campaign_outlined, 'Broadcast\nNotice', AppColors.surfaceVariant),
            _buildActionButton(Icons.category_outlined, 'Categories', AppColors.surfaceVariant),
            _buildActionButton(Icons.security_outlined, 'Audit Logs', AppColors.surfaceVariant),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color bgColor) {
    return Container(
      width: 75,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: AppColors.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHubBanner() {
    return Column(
      children: [
        Container(
          height: 120,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            image: const DecorationImage(
              image: AssetImage('assets/images/harvest_ai_assistant_bg.jpg'), // using placeholder
              fit: BoxFit.cover,
            ),
            color: AppColors.primaryContainer, // Fallback color
          ),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'PRIMARY TRANSIT NODE',
                      style: TextStyle(
                        color: AppColors.secondaryContainer,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      'Malir Collection Center',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Active Depots: 4/4',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
            boxShadow: [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.local_shipping_outlined, size: 16, color: AppColors.primaryContainer),
                  SizedBox(width: 8),
                  Text(
                    '18 outbound transport vans en route',
                    style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
              const Text(
                'Inspect Hubs',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryContainer,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Row(
              children: [
                Text(
                  'Recent Marketplace Activity',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.circle, size: 10, color: AppColors.primaryContainer),
              ],
            ),
            Text(
              'View All',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryContainer,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _data!.activities.length,
          separatorBuilder: (context, index) => const Divider(height: 24, color: AppColors.surfaceVariant),
          itemBuilder: (context, index) {
            final activity = _data!.activities[index];
            return _buildActivityItem(activity);
          },
        ),
      ],
    );
  }

  Widget _buildActivityItem(MarketplaceActivity activity) {
    IconData icon;
    Color iconBgColor;
    Color iconColor;

    switch (activity.type) {
      case 'restock':
        icon = Icons.inventory_2_outlined;
        iconBgColor = AppColors.secondaryContainer;
        iconColor = AppColors.onSurface;
        break;
      case 'application':
        icon = Icons.person_add_alt_1_outlined;
        iconBgColor = AppColors.errorContainer;
        iconColor = AppColors.error;
        break;
      case 'order':
        icon = Icons.check_circle_outline;
        iconBgColor = AppColors.surfaceVariant;
        iconColor = AppColors.onSurface;
        break;
      case 'flag':
        icon = Icons.security_outlined;
        iconBgColor = AppColors.secondaryContainer;
        iconColor = AppColors.onSurface;
        break;
      default:
        icon = Icons.info_outline;
        iconBgColor = AppColors.surfaceVariant;
        iconColor = AppColors.onSurface;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconBgColor,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    activity.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    activity.timeAgo,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                activity.description,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              if (activity.badgeText != null || activity.subtext != null)
                Row(
                  children: [
                    if (activity.badgeText != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: activity.type == 'application' 
                              ? AppColors.errorContainer 
                              : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          activity.badgeText!,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: activity.type == 'application' 
                                ? AppColors.error 
                                : AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (activity.subtext != null)
                      Text(
                        activity.subtext!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.primaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}
