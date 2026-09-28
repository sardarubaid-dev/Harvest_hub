import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/order_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../theme/app_theme.dart';
import 'farmer_order_detail_screen.dart';

class FarmerOrdersTab extends StatefulWidget {
  const FarmerOrdersTab({super.key});

  @override
  State<FarmerOrdersTab> createState() => _FarmerOrdersTabState();
}

class _FarmerOrdersTabState extends State<FarmerOrdersTab>
    with SingleTickerProviderStateMixin {
  final DatabaseService _dbService = DatabaseService();
  late TabController _tabController;
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  final List<String> _tabs = [
    'All',
    'Pending',
    'Confirmed',
    'Ready for Pickup',
    'Completed',
    'Cancelled',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

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

  void _openOrderDetail(OrderModel order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FarmerOrderDetailScreen(order: order),
      ),
    );
  }

  Future<void> _quickAdvanceStatus(OrderModel order) async {
    String? nextStatus;
    final status = order.status.toLowerCase();
    if (status == 'pending') {
      nextStatus = 'Confirmed';
    } else if (status == 'confirmed') {
      nextStatus = 'Ready for Pickup';
    } else if (status == 'ready for pickup') {
      nextStatus = 'Completed';
    }

    if (nextStatus == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Advance to $nextStatus?'),
        content: Text(
          'Update order #${order.id.length > 6 ? order.id.substring(0, 6).toUpperCase() : order.id} to "$nextStatus"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _getStatusColor(nextStatus!),
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _dbService.updateOrderStatus(order.id, nextStatus);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Order updated to $nextStatus'),
              backgroundColor: AppColors.primary,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update status: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
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
          'Customer Orders',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.onSurfaceVariant,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
        ),
      ),
      body: Column(
        children: [
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            color: AppColors.surface,
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (val) {
                  setState(() => _searchQuery = val.trim().toLowerCase());
                },
                decoration: InputDecoration(
                  hintText: 'Search by Order ID or customer name...',
                  hintStyle: TextStyle(fontSize: 13, color: AppColors.outline),
                  prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.outline),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18, color: AppColors.outline),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                ),
              ),
            ),
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.surfaceVariant),

          Expanded(
            child: StreamBuilder<List<OrderModel>>(
              stream: _dbService.streamFarmerOrders(farmer.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                        const SizedBox(height: 12),
                        Text(
                          'Error loading customer orders',
                          style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                final allOrders = snapshot.data ?? [];

                return TabBarView(
                  controller: _tabController,
                  children: _tabs.map((tab) {
                    final filtered = allOrders.where((order) {
                      
                      if (tab != 'All' &&
                          order.status.toLowerCase() != tab.toLowerCase()) {
                        return false;
                      }

                      if (_searchQuery.isNotEmpty) {
                        final idMatch = order.id.toLowerCase().contains(_searchQuery);
                        final nameMatch = (order.customerName ?? '')
                            .toLowerCase()
                            .contains(_searchQuery);
                        if (!idMatch && !nameMatch) return false;
                      }

                      return true;
                    }).toList();

                    return _buildOrderList(filtered, tab);
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList(List<OrderModel> orders, String tabName) {
    if (orders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 60,
                color: AppColors.outline,
              ),
              const SizedBox(height: 14),
              Text(
                _searchQuery.isNotEmpty
                    ? 'No orders match "$_searchQuery"'
                    : (tabName == 'All'
                        ? 'No customer orders received yet'
                        : 'No $tabName orders at this time'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Orders placed for your produce will appear here.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildOrderCard(order);
      },
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    final status = order.status;
    final statusColor = _getStatusColor(status);
    final dateStr = DateFormat('dd MMM, hh:mm a').format(order.createdAt);
    final shortId = order.id.length > 6 ? order.id.substring(0, 6).toUpperCase() : order.id;

    String? nextActionLabel;
    final lower = status.toLowerCase();
    if (lower == 'pending') {
      nextActionLabel = 'Confirm';
    } else if (lower == 'confirmed') {
      nextActionLabel = 'Ready for Pickup';
    } else if (lower == 'ready for pickup') {
      nextActionLabel = 'Complete';
    }

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.surfaceVariant),
      ),
      child: InkWell(
        onTap: () => _openOrderDetail(order),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
                          fontSize: 15,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Rs. ${order.totalAmount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person_outline, size: 16, color: AppColors.outline),
                      const SizedBox(width: 6),
                      Text(
                        order.customerName ?? 'Customer',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 14, color: AppColors.outline),
                      const SizedBox(width: 4),
                      Text(
                        dateStr,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (order.pickupSlotTime != null && order.pickupSlotTime!.isNotEmpty)
                Row(
                  children: [
                    const Icon(Icons.schedule, size: 14, color: AppColors.outline),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Pickup: ${order.pickupSlotTime}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

              const Divider(height: 18, color: AppColors.surfaceVariant),

              Text(
                '${order.items.length} ${order.items.length == 1 ? 'item' : 'items'}: ${order.items.map((it) => '${it.quantity.toInt()}x ${it.productName}').join(', ')}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _openOrderDetail(order),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 36),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      child: const Text('View Details'),
                    ),
                  ),
                  if (nextActionLabel != null) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _quickAdvanceStatus(order),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _getStatusColor(
                            nextActionLabel == 'Confirm'
                                ? 'Confirmed'
                                : (nextActionLabel == 'Ready for Pickup'
                                    ? 'Ready for Pickup'
                                    : 'Completed'),
                          ),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(0, 36),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          textStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: Text(nextActionLabel),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
