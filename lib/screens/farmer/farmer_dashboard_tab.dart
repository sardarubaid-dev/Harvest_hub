import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:harvest_hub/theme/app_theme.dart';
import 'package:harvest_hub/providers/auth_provider.dart';
import 'package:harvest_hub/services/database_service.dart';
import 'package:harvest_hub/models/order_model.dart';

class FarmerDashboardTab extends StatefulWidget {
  const FarmerDashboardTab({super.key});

  @override
  State<FarmerDashboardTab> createState() => _FarmerDashboardTabState();
}

class _FarmerDashboardTabState extends State<FarmerDashboardTab> {
  final DatabaseService _dbService = DatabaseService();
  bool _isStoreOpen = true; // This should ideally be synced with farmer model in DB

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final farmer = authProvider.currentFarmer;

    if (farmer == null) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(farmer.farmName),
              const SizedBox(height: 24),
              _buildStoreStatusToggle(),
              const SizedBox(height: 24),
              _buildQuickStats(farmer.id),
              const SizedBox(height: 24),
              _buildRecentOrders(farmer.id),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String farmName) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.agriculture, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                farmName.isNotEmpty ? farmName : 'Farmer Dashboard',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              const Text(
                'Dashboard Overview',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {},
        ),
        const CircleAvatar(
          backgroundColor: AppColors.primaryContainer,
          radius: 16,
          child: Icon(Icons.person, color: Colors.white, size: 20),
        ),
      ],
    );
  }

  Widget _buildStoreStatusToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isStoreOpen ? AppColors.secondaryContainer : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isStoreOpen ? 'Farm Store Open' : 'Farm Store Closed',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _isStoreOpen ? AppColors.onSecondaryContainer : AppColors.onSurfaceVariant,
                ),
              ),
              Text(
                _isStoreOpen ? 'Accepting Orders' : 'Not Accepting Orders',
                style: TextStyle(
                  fontSize: 12,
                  color: _isStoreOpen ? AppColors.onSecondaryContainer : AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          Switch(
            value: _isStoreOpen,
            onChanged: (val) {
              setState(() {
                _isStoreOpen = val;
                // TODO: Update Firebase if `isOpen` exists on FarmerModel
              });
            },
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(String farmerId) {
    return StreamBuilder<List<OrderModel>>(
      stream: _dbService.streamFarmerOrders(farmerId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final orders = snapshot.data!;
        
        int pending = orders.where((o) => o.status.toLowerCase() == 'pending').length;
        int completed = orders.where((o) => o.status.toLowerCase() == 'completed').length;
        double revenue = 0.0;
        for (var o in orders) {
          if (o.status.toLowerCase() == 'completed') {
            revenue += o.totalAmount;
          }
        }

        return Row(
          children: [
            Expanded(child: _buildStatCard('Pending', pending.toString(), Icons.pending_actions, AppColors.errorContainer, AppColors.error)),
            const SizedBox(width: 16),
            Expanded(child: _buildStatCard('Completed', completed.toString(), Icons.check_circle_outline, AppColors.secondaryContainer, AppColors.onSecondaryContainer)),
            const SizedBox(width: 16),
            Expanded(child: _buildStatCard('Revenue', '\$${revenue.toStringAsFixed(0)}', Icons.attach_money, AppColors.primaryContainer, AppColors.onPrimary)),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color bgColor, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: iconColor),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: iconColor),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentOrders(String farmerId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Orders',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.onSurface),
        ),
        const SizedBox(height: 12),
        StreamBuilder<List<OrderModel>>(
          stream: _dbService.streamFarmerOrders(farmerId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No orders yet."));
            }

            final orders = snapshot.data!.take(5).toList();

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final order = orders[index];
                return Card(
                  elevation: 0,
                  color: AppColors.surfaceVariant,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    title: Text('Order #${order.id.substring(0, 6)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${order.items.length} items • \$${order.totalAmount.toStringAsFixed(2)}'),
                    trailing: _buildStatusBadge(order.status),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor = AppColors.surfaceVariant;
    Color textColor = AppColors.onSurfaceVariant;
    
    if (status.toLowerCase() == 'pending') {
      bgColor = Colors.orange.shade100;
      textColor = Colors.orange.shade800;
    } else if (status.toLowerCase() == 'completed') {
      bgColor = AppColors.secondaryContainer;
      textColor = AppColors.onSecondaryContainer;
    } else if (status.toLowerCase() == 'in transit') {
      bgColor = Colors.blue.shade100;
      textColor = Colors.blue.shade800;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textColor),
      ),
    );
  }
}
