import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:harvest_hub/theme/app_theme.dart';
import 'package:harvest_hub/providers/auth_provider.dart';
import 'package:harvest_hub/services/database_service.dart';
import 'package:harvest_hub/models/order_model.dart';

class FarmerOrdersTab extends StatefulWidget {
  const FarmerOrdersTab({super.key});

  @override
  State<FarmerOrdersTab> createState() => _FarmerOrdersTabState();
}

class _FarmerOrdersTabState extends State<FarmerOrdersTab> with SingleTickerProviderStateMixin {
  final DatabaseService _dbService = DatabaseService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final farmer = authProvider.currentFarmer;

    if (farmer == null) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Customer Orders', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.background,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.onSurfaceVariant,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'In Transit'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: StreamBuilder<List<OrderModel>>(
        stream: _dbService.streamFarmerOrders(farmer.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          final allOrders = snapshot.data ?? [];
          
          final pendingOrders = allOrders.where((o) => o.status.toLowerCase() == 'pending').toList();
          final transitOrders = allOrders.where((o) => o.status.toLowerCase() == 'in transit').toList();
          final completedOrders = allOrders.where((o) => o.status.toLowerCase() == 'completed').toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildOrderList(pendingOrders),
              _buildOrderList(transitOrders),
              _buildOrderList(completedOrders),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOrderList(List<OrderModel> orders) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 64, color: AppColors.outline),
            const SizedBox(height: 16),
            Text('No orders found.', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 16)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Order #${order.id.substring(0, 6)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('\$${order.totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Customer: ${order.customerName}', style: TextStyle(color: AppColors.onSurfaceVariant)),
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 8),
                const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...order.items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${item.quantity}x ${item.productName}'),
                      Text('\$${(item.price * item.quantity).toStringAsFixed(2)}'),
                    ],
                  ),
                )),
                const SizedBox(height: 16),
                _buildActionButtons(order),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(OrderModel order) {
    String status = order.status.toLowerCase();
    
    if (status == 'pending') {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _dbService.updateOrderStatus(order.id, 'Disputed'),
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _dbService.updateOrderStatus(order.id, 'In Transit'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              child: const Text('Mark In Transit'),
            ),
          ),
        ],
      );
    } else if (status == 'in transit') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _dbService.updateOrderStatus(order.id, 'Completed'),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondaryContainer, foregroundColor: AppColors.onSecondaryContainer),
          child: const Text('Mark Completed'),
        ),
      );
    }
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(order.status, style: TextStyle(color: AppColors.onSurfaceVariant, fontWeight: FontWeight.bold)),
    );
  }
}
