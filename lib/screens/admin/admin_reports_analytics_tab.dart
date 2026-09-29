import 'package:flutter/material.dart';
import 'package:harvest_hub/theme/app_theme.dart';
import 'package:harvest_hub/services/database_service.dart';
import 'package:harvest_hub/models/order_model.dart';
import 'package:harvest_hub/models/farmer_model.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class AdminReportsAnalyticsTab extends StatefulWidget {
  const AdminReportsAnalyticsTab({super.key});

  @override
  State<AdminReportsAnalyticsTab> createState() => _AdminReportsAnalyticsTabState();
}

class _AdminReportsAnalyticsTabState extends State<AdminReportsAnalyticsTab> {
  final DatabaseService _db = DatabaseService();
  int _selectedTimeFilterIndex = 0;
  final List<String> _timeFilters = ['All Time', 'Today', 'This Week', 'This Month'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: StreamBuilder<List<OrderModel>>(
            stream: _db.streamAllOrders(),
            builder: (context, orderSnapshot) {
              if (orderSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final orders = orderSnapshot.data ?? [];
              
              return StreamBuilder<List<FarmerModel>>(
                stream: _db.streamAllFarmers(),
                builder: (context, farmerSnapshot) {
                  final farmers = farmerSnapshot.data ?? [];
                  return _buildContent(orders, farmers);
                }
              );
            }
          ),
        ),
      ),
    );
  }

  Widget _buildContent(List<OrderModel> orders, List<FarmerModel> farmers) {
    // Filter orders by time
    final now = DateTime.now();
    final filteredOrders = orders.where((order) {
      if (_selectedTimeFilterIndex == 0) return true; // All Time
      
      final orderDate = order.createdAt;
      if (_selectedTimeFilterIndex == 1) { // Today
        return orderDate.year == now.year && orderDate.month == now.month && orderDate.day == now.day;
      } else if (_selectedTimeFilterIndex == 2) { // This Week
        final difference = now.difference(orderDate).inDays;
        return difference <= 7;
      } else if (_selectedTimeFilterIndex == 3) { // This Month
        return orderDate.year == now.year && orderDate.month == now.month;
      }
      return true;
    }).toList();

    double totalGmv = 0;
    int completedOrders = 0;
    int totalValidOrders = 0;
    
    Map<String, int> farmerOrderCount = {};
    Map<String, double> farmerRevenue = {};

    for (var order in filteredOrders) {
      if (order.status != 'cancelled') {
        totalGmv += order.totalAmount;
        totalValidOrders++;
        if (order.status == 'completed') {
          completedOrders++;
        }
        
        String farmerId = order.farmerId ?? 'unknown';
        farmerOrderCount[farmerId] = (farmerOrderCount[farmerId] ?? 0) + 1;
        farmerRevenue[farmerId] = (farmerRevenue[farmerId] ?? 0) + order.totalAmount;
      }
    }

    double successRate = totalValidOrders > 0 ? (completedOrders / totalValidOrders) * 100 : 0;
    double hubFees = completedOrders * 20.0;
    double farmerPayouts = totalGmv - hubFees;

    var sortedFarmers = farmerOrderCount.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 24),
        _buildTitleRow(),
        const SizedBox(height: 16),
        _buildTimeFilters(),
        const SizedBox(height: 24),
        _buildGmvSection(totalGmv),
        const SizedBox(height: 16),
        _buildMetricsRow(hubFees, completedOrders, farmerPayouts),
        const SizedBox(height: 16),
        _buildSuccessRateCard(successRate),
        const SizedBox(height: 24),
        _buildTopHubsSection(sortedFarmers, farmers, farmerRevenue),
        const SizedBox(height: 24),
        _buildReportsExportSection(totalGmv, completedOrders, hubFees, farmerPayouts, totalValidOrders),
        const SizedBox(height: 24),
        _buildGenerateReportButton(totalGmv, completedOrders, hubFees, farmerPayouts, totalValidOrders),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppColors.primaryContainer, borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.eco, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('HarvestHub', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: AppColors.secondaryContainer, borderRadius: BorderRadius.circular(4)),
                  child: const Text('ADMIN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.onSecondaryContainer)),
                ),
              ],
            ),
            const Text('Reports & Analytics', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
          ],
        ),
        ),
        Stack(
          children: [
            IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                child: const Text('0', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
        const CircleAvatar(backgroundColor: AppColors.primaryContainer, radius: 16, child: Icon(Icons.person, color: Colors.white, size: 20)),
      ],
    );
  }

  Widget _buildTitleRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Platform Analytics', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
              SizedBox(height: 4),
              Text('Real-time marketplace revenue & performance', style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.secondaryContainer, shape: BoxShape.circle),
          child: const Icon(Icons.show_chart, color: AppColors.onSecondaryContainer),
        ),
      ],
    );
  }

  Widget _buildTimeFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _timeFilters.asMap().entries.map((entry) {
          final index = entry.key;
          final label = entry.value;
          final isSelected = index == _selectedTimeFilterIndex;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTimeFilterIndex = index;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryContainer : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
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

  Widget _buildGmvSection(double totalGmv) {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.payments_outlined, size: 16, color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(width: 8),
                  const Text('GROSS MERCHANDISE VOL (GMV)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant, letterSpacing: 0.5)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: AppColors.secondaryContainer, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: const [
                    Icon(Icons.trending_up, size: 12, color: AppColors.onSecondaryContainer),
                    SizedBox(width: 4),
                    Text('Live', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.onSecondaryContainer)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Rs. ${NumberFormat.compact().format(totalGmv)}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
          const SizedBox(height: 4),
          const Text('Total transaction volume', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildMetricsRow(double hubFees, int runs, double payouts) {
    return Row(
      children: [
        Expanded(
          child: Container(
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
                  children: const [
                    Icon(Icons.pie_chart_outline, size: 16, color: AppColors.onSurfaceVariant),
                    SizedBox(width: 6),
                    Text('HUB FEES', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant)),
                  ],
                ),
                const SizedBox(height: 4),
                const Text('Rs. 20 / completed order', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                const SizedBox(height: 16),
                Text('Rs. ${NumberFormat.compact().format(hubFees)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryContainer)),
                const SizedBox(height: 4),
                Text('$runs total runs', style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
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
                  children: const [
                    Icon(Icons.account_balance_wallet_outlined, size: 16, color: AppColors.onSurfaceVariant),
                    SizedBox(width: 6),
                    Text('FARMER PAYOUTS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant)),
                  ],
                ),
                const SizedBox(height: 4),
                const Text('Disbursed directly', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                const SizedBox(height: 16),
                Text('Rs. ${NumberFormat.compact().format(payouts)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                const SizedBox(height: 4),
                Row(
                  children: const [
                    Icon(Icons.check_circle_outline, size: 12, color: AppColors.primaryContainer),
                    SizedBox(width: 4),
                    Text('100% cleared', style: TextStyle(fontSize: 11, color: AppColors.primaryContainer, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessRateCard(double successRate) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EFE8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.secondaryContainer, shape: BoxShape.circle),
            child: const Icon(Icons.verified, color: AppColors.onSecondaryContainer),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Fulfillment Success Rate', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                Text('Completed orders vs total', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
          Text('${successRate.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryContainer)),
        ],
      ),
    );
  }

  Widget _buildTopHubsSection(List<MapEntry<String, int>> sortedFarmers, List<FarmerModel> allFarmers, Map<String, double> revenueMap) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Row(
              children: [
                Icon(Icons.storefront, size: 18, color: AppColors.primaryContainer),
                SizedBox(width: 8),
                Text('Top Hubs & Producers', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (sortedFarmers.isEmpty)
          const Text("No orders found to determine top producers.")
        else
          ...List.generate(sortedFarmers.length > 5 ? 5 : sortedFarmers.length, (index) {
            String farmerId = sortedFarmers[index].key;
            int orderCount = sortedFarmers[index].value;
            double revenue = revenueMap[farmerId] ?? 0;
            
            FarmerModel? farmer;
            try {
              farmer = allFarmers.firstWhere((f) => f.id == farmerId);
            } catch (_) {}

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildHubItem(
                rank: '#${index + 1}',
                title: farmer?.farmName ?? 'Unknown Producer',
                subtitle: farmer?.location ?? 'Unknown Location',
                orders: '$orderCount orders',
                revenue: 'Rs. ${NumberFormat.compact().format(revenue)}',
              ),
            );
          }),
      ],
    );
  }

  Widget _buildHubItem({required String rank, required String title, required String subtitle, required String orders, required String revenue}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: const Color(0xFFF0F5F0), borderRadius: BorderRadius.circular(8)),
            alignment: Alignment.center,
            child: Text(rank, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryContainer)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        subtitle,
                        style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Text('•', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                    ),
                    Text(orders, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryContainer)),
                  ],
                ),
              ],
            ),
          ),
          Text(revenue, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
        ],
      ),
    );
  }

  Widget _buildReportsExportSection(double totalGmv, int completedOrders, double hubFees, double farmerPayouts, int totalValidOrders) {
    return Column(
      children: [
        Row(
          children: const [
            Icon(Icons.download, size: 18, color: AppColors.primaryContainer),
            SizedBox(width: 8),
            Text('Reports & Ledger Exports', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
          ],
        ),
        const SizedBox(height: 16),
        _buildExportItem(
          'Export Tax & Revenue CSV',
          'Includes hub fees and provincial tax ledger',
          Icons.table_chart_outlined,
          AppColors.secondaryContainer,
          () {
            final csvData = "Report Type,Amount\nTotal GMV,$totalGmv\nHub Fees,$hubFees\nFarmer Payouts,$farmerPayouts\nCompleted Orders,$completedOrders";
            _downloadFile('Tax_Revenue_Report', csvData, 'csv');
          }
        ),
        const SizedBox(height: 12),
        _buildExportItem(
          'Monthly Farmer Statement Text',
          'Batch disbursements, weights, and returns',
          Icons.description_outlined,
          AppColors.surfaceVariant,
          () {
            final txtData = "MONTHLY FARMER STATEMENT\n-------------------------\nTotal Orders: $completedOrders\nTotal Valid Orders: $totalValidOrders\nTotal Farmer Payouts: Rs. ${farmerPayouts.toStringAsFixed(2)}\nTotal Platform GMV: Rs. ${totalGmv.toStringAsFixed(2)}";
            _downloadFile('Farmer_Statement', txtData, 'txt');
          }
        ),
      ],
    );
  }

  void _downloadFile(String title, String content, String extension) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 24),
              Expanded(child: Text('Downloading $title...')),
            ],
          ),
        );
      }
    );

    try {
      Directory? directory;
      
      // On Android, we write directly to the public Download folder
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) throw Exception("Could not find directory");

      final fileName = '${title}_${DateTime.now().millisecondsSinceEpoch}.$extension';
      final file = File('${directory.path}/$fileName');
      
      await file.writeAsString(content);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully saved to Downloads folder as $fileName'),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to download: $e')),
        );
      }
    }
  }

  Widget _buildExportItem(String title, String subtitle, IconData icon, Color iconBg, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF7FAF3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: AppColors.onSurface, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                ],
              ),
            ),
            const Icon(Icons.file_download_outlined, color: AppColors.onSurface),
          ],
        ),
      ),
    );
  }

  Widget _buildGenerateReportButton(double totalGmv, int completedOrders, double hubFees, double farmerPayouts, int totalValidOrders) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: () {
            final csvData = "Metric,Value\nTotal Orders,$totalValidOrders\nCompleted Orders,$completedOrders\nGMV,$totalGmv\nHub Fees,$hubFees\nFarmer Payouts,$farmerPayouts";
            _downloadFile('Detailed_Audit_Report', csvData, 'csv');
          },
          icon: const Icon(Icons.bar_chart, color: Colors.white),
          label: const Text('Generate Detailed Audit Report'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryContainer,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(50),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Automated signed reconciliation generated in 30 seconds',
          style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
