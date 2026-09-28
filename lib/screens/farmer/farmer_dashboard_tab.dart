import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/order_model.dart';
import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../theme/app_theme.dart';
import 'add_product_screen.dart';
import 'farmer_categories_screen.dart';
import 'farmer_market_pickup_screen.dart';
import 'farmer_notifications_screen.dart';
import 'farmer_order_detail_screen.dart';

class FarmerDashboardTab extends StatefulWidget {
  final Function(int)? onNavigateTab;

  const FarmerDashboardTab({super.key, this.onNavigateTab});

  @override
  State<FarmerDashboardTab> createState() => _FarmerDashboardTabState();
}

class _FarmerDashboardTabState extends State<FarmerDashboardTab> {
  final DatabaseService _dbService = DatabaseService();
  bool _isStoreOpen = true;

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppColors.warning;
      case 'confirmed':
        return const Color(0xFF1976D2);
      case 'ready for pickup':
        return const Color(0xFF673AB7);
      case 'completed':
        return AppColors.primary;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.outline;
    }
  }

  void _openAddProduct() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddProductScreen()),
    );
  }

  void _openCategories() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const FarmerCategoriesScreen(isSelectionMode: false),
      ),
    );
  }

  void _openMarketPickup() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FarmerMarketPickupScreen(),
      ),
    );
  }

  void _openNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FarmerNotificationsScreen(),
      ),
    );
  }

  void _openOrderDetail(OrderModel order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FarmerOrderDetailScreen(order: order),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
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

    if (confirmed == true && context.mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.logout();
      if (context.mounted) {
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

    final String farmerName = user?.name ?? 'Farmer';
    final String farmName = farmer.farmName.isNotEmpty
        ? farmer.farmName
        : 'Local Farm';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.eco, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HARVESTHUB',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.outline,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  'Farmer Portal',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: AppColors.onSurface),
            tooltip: 'Notifications',
            onPressed: _openNotifications,
          ),
          PopupMenuButton<String>(
            tooltip: 'Farmer Account',
            icon: const CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primaryContainer,
              child: Icon(Icons.person, color: Colors.white, size: 20),
            ),
            onSelected: (val) {
              if (val == 'profile') {
                widget.onNavigateTab?.call(3);
              } else if (val == 'logout') {
                _confirmLogout(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person_outline, size: 18, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text('My Profile'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 18, color: AppColors.error),
                    SizedBox(width: 8),
                    Text('Sign Out', style: TextStyle(color: AppColors.error)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: StreamBuilder<List<ProductModel>>(
        stream: _dbService.streamProductsByFarmer(farmer.id),
        builder: (context, productSnapshot) {
          return StreamBuilder<List<OrderModel>>(
            stream: _dbService.streamFarmerOrders(farmer.id),
            builder: (context, orderSnapshot) {
              if (productSnapshot.connectionState == ConnectionState.waiting ||
                  orderSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              final products = productSnapshot.data ?? [];
              final orders = orderSnapshot.data ?? [];

              final int totalProducts = products.length;
              final int activeProducts =
                  products.where((p) => p.isAvailable && p.quantity > 0).length;
              final int outOfStockProducts =
                  products.where((p) => !p.isAvailable || p.quantity == 0).length;
              final lowStockProducts = products
                  .where((p) => p.isAvailable && p.quantity > 0 && p.quantity < 5)
                  .toList();

              final int totalOrders = orders.length;
              final int pendingOrders =
                  orders.where((o) => o.status.toLowerCase() == 'pending').length;
              final int confirmedOrders =
                  orders.where((o) => o.status.toLowerCase() == 'confirmed').length;
              final int readyOrders =
                  orders.where((o) => o.status.toLowerCase() == 'ready for pickup').length;
              final int completedOrders =
                  orders.where((o) => o.status.toLowerCase() == 'completed').length;

              double totalRevenue = 0;
              for (var o in orders.where((o) => o.status.toLowerCase() == 'completed')) {
                totalRevenue += o.totalAmount;
              }

              return ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.surfaceVariant),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: const BoxDecoration(
                            color: AppColors.onTertiaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.storefront,
                            size: 28,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'WELCOME BACK',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                farmerName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      farmName,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(
                                    Icons.verified,
                                    color: AppColors.primary,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 2),
                                  const Text(
                                    'Verified',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.surfaceVariant),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: _isStoreOpen
                                ? AppColors.primary
                                : AppColors.outline,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _isStoreOpen
                                ? 'Farm Store Open - Accepting Orders'
                                : 'Farm Store Closed - Paused Orders',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurface,
                            ),
                          ),
                        ),
                        Switch(
                          value: _isStoreOpen,
                          onChanged: (val) {
                            setState(() => _isStoreOpen = val);
                          },
                          activeThumbColor: Colors.white,
                          activeTrackColor: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'Marketplace Activity',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 10),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.45,
                    children: [
                      _buildMetricCard(
                        title: 'Total Products',
                        value: '$totalProducts',
                        subtitle: '$activeProducts in-stock',
                        icon: Icons.inventory_2_outlined,
                        color: AppColors.primary,
                        onTap: () => widget.onNavigateTab?.call(1),
                      ),
                      _buildMetricCard(
                        title: 'Received Orders',
                        value: '$totalOrders',
                        subtitle: '$pendingOrders need review',
                        icon: Icons.receipt_long_outlined,
                        color: pendingOrders > 0
                            ? AppColors.warning
                            : AppColors.primary,
                        onTap: () => widget.onNavigateTab?.call(2),
                      ),
                      _buildMetricCard(
                        title: 'Unavailable',
                        value: '$outOfStockProducts',
                        subtitle: '${lowStockProducts.length} low in stock',
                        icon: Icons.warning_amber_rounded,
                        color: outOfStockProducts > 0
                            ? AppColors.error
                            : AppColors.outline,
                        onTap: () => widget.onNavigateTab?.call(1),
                      ),
                      _buildMetricCard(
                        title: 'Completed Revenue',
                        value: 'Rs. ${totalRevenue.toStringAsFixed(0)}',
                        subtitle: '$completedOrders orders fulfilled',
                        icon: Icons.payments_outlined,
                        color: AppColors.primary,
                        onTap: () => widget.onNavigateTab?.call(2),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (lowStockProducts.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                color: AppColors.warning,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'Low Stock Alert',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.warning,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.warning,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${lowStockProducts.length} items',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            lowStockProducts
                                .map((p) => '${p.name} (${p.quantity.toInt()} ${p.unit} left)')
                                .join(', '),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () => widget.onNavigateTab?.call(1),
                            child: const Row(
                              children: [
                                Text(
                                  'Update inventory now',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.warning,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_forward,
                                  color: AppColors.warning,
                                  size: 14,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  const Text(
                    'Order Status Breakdown',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.surfaceVariant),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatusSummaryItem(
                          'Pending',
                          '$pendingOrders',
                          AppColors.warning,
                        ),
                        Container(width: 1, height: 32, color: AppColors.surfaceVariant),
                        _buildStatusSummaryItem(
                          'Confirmed',
                          '$confirmedOrders',
                          const Color(0xFF1976D2),
                        ),
                        Container(width: 1, height: 32, color: AppColors.surfaceVariant),
                        _buildStatusSummaryItem(
                          'Ready',
                          '$readyOrders',
                          const Color(0xFF673AB7),
                        ),
                        Container(width: 1, height: 32, color: AppColors.surfaceVariant),
                        _buildStatusSummaryItem(
                          'Completed',
                          '$completedOrders',
                          AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 10),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 2.8,
                    children: [
                      _buildActionButton(
                        icon: Icons.add,
                        label: 'Add Product',
                        isPrimary: true,
                        onTap: _openAddProduct,
                      ),
                      _buildActionButton(
                        icon: Icons.inventory_2_outlined,
                        label: 'My Products',
                        onTap: () => widget.onNavigateTab?.call(1),
                      ),
                      _buildActionButton(
                        icon: Icons.receipt_long_outlined,
                        label: 'Customer Orders',
                        onTap: () => widget.onNavigateTab?.call(2),
                      ),
                      _buildActionButton(
                        icon: Icons.category_outlined,
                        label: 'Categories',
                        onTap: _openCategories,
                      ),
                      _buildActionButton(
                        icon: Icons.storefront_outlined,
                        label: 'Pickup & Markets',
                        onTap: _openMarketPickup,
                      ),
                      _buildActionButton(
                        icon: Icons.notifications_outlined,
                        label: 'Notifications',
                        onTap: _openNotifications,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Recent Orders',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.onTertiaryContainer,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Live',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: () => widget.onNavigateTab?.call(2),
                        child: const Text(
                          'View All >',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (orders.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.surfaceVariant),
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 40,
                              color: AppColors.outline,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'No customer orders received yet',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...orders.take(4).map((order) {
                      return _buildRecentOrderCard(order);
                    }),
                  const SizedBox(height: 20),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.surfaceVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 20),
                Icon(Icons.chevron_right, size: 16, color: AppColors.outline),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSummaryItem(String label, String count, Color color) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    if (isPrimary) {
      return ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 16),
        label: Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryContainer,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 10),
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16, color: AppColors.primary),
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.onSurface,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.surfaceVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 10),
      ),
    );
  }

  Widget _buildRecentOrderCard(OrderModel order) {
    final status = order.status;
    final statusColor = _getStatusColor(status);
    final shortId = order.id.length > 6 ? order.id.substring(0, 6).toUpperCase() : order.id;
    final timeStr = DateFormat('dd MMM, hh:mm a').format(order.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    '#$shortId',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                'Rs. ${order.totalAmount.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order.customerName ?? 'Customer',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              Text(
                timeStr,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${order.items.length} items • ${order.items.map((i) => i.productName).join(', ')}',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              InkWell(
                onTap: () => _openOrderDetail(order),
                child: const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Text(
                    'Details >',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
