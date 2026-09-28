import 'package:flutter/material.dart';
import 'package:harvest_hub/theme/app_theme.dart';
import 'package:harvest_hub/services/database_service.dart';
import 'package:harvest_hub/models/order_model.dart';
import 'package:harvest_hub/models/customer_model.dart';
import 'package:harvest_hub/models/farmer_model.dart';
import 'package:intl/intl.dart';

class AdminOrderDetailsScreen extends StatefulWidget {
  final String orderId;

  const AdminOrderDetailsScreen({super.key, required this.orderId});

  @override
  State<AdminOrderDetailsScreen> createState() => _AdminOrderDetailsScreenState();
}

class _AdminOrderDetailsScreenState extends State<AdminOrderDetailsScreen> {
  final _db = DatabaseService();
  bool _isLoading = true;
  OrderModel? _order;
  CustomerModel? _customer;
  FarmerModel? _farmer;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    try {
      final order = await _db.getOrder(widget.orderId);
      if (order != null) {
        final customer = await _db.getCustomer(order.customerId);
        FarmerModel? farmer;
        if (order.farmerId != null) {
          farmer = await _db.getFarmer(order.farmerId!);
        }

        if (mounted) {
          setState(() {
            _order = order;
            _customer = customer;
            _farmer = farmer;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Order Details', style: TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.onSurface),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _order == null
              ? const Center(child: Text('Order not found'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 24),
                      if (_customer != null) _buildCustomerCard(),
                      if (_customer != null) const SizedBox(height: 16),
                      if (_farmer != null) _buildFarmerCard(),
                      if (_farmer != null) const SizedBox(height: 24),
                      _buildTimeline(),
                      const SizedBox(height: 24),
                      _buildItemsList(),
                      const SizedBox(height: 24),
                      _buildFinancialSummary(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ID: ${_order!.id.toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              Text(DateFormat('MMM d, y, h:mm a').format(_order!.createdAt), style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _order!.status.toUpperCase(),
              style: TextStyle(color: _getStatusColor(), fontWeight: FontWeight.bold, fontSize: 12),
            ),
          )
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (_order!.status.toLowerCase()) {
      case 'ready': return AppColors.onSecondaryContainer;
      case 'completed': return AppColors.primaryContainer;
      case 'cancelled': return AppColors.error;
      default: return AppColors.onSurfaceVariant;
    }
  }

  Widget _buildCustomerCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Customer Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const Divider(height: 24),
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primaryContainer,
                child: Text(_customer?.name.substring(0, 1).toUpperCase() ?? '?', style: const TextStyle(color: Colors.white)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_customer?.name ?? 'Unknown Customer', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(_customer?.phone ?? 'No contact', style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
                    Text(_customer?.address ?? 'No location', style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFarmerCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Farmer / Hub Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const Divider(height: 24),
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: AppColors.secondaryContainer,
                child: Icon(Icons.storefront, color: AppColors.onSecondaryContainer),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_farmer?.farmName ?? 'Unknown Farm', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(_farmer?.contactNumber ?? 'No contact', style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
                    Text(_farmer?.location ?? 'No location', style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    final status = _order!.status.toLowerCase();
    bool isReady = status == 'ready' || status == 'completed';
    bool isCompleted = status == 'completed';
    bool isCancelled = status == 'cancelled';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Order Timeline', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 16),
          _buildTimelineStep(
            'Order Placed',
            DateFormat('MMM d, h:mm a').format(_order!.createdAt),
            true,
            isCancelled,
            isLast: false,
          ),
          _buildTimelineStep(
            'Processing at Hub',
            isReady ? 'Hub received items' : 'Waiting for items...',
            isReady,
            isCancelled,
            isLast: false,
          ),
          _buildTimelineStep(
            'Ready for Pickup',
            isReady ? 'Items packaged' : 'Pending',
            isReady,
            isCancelled,
            isLast: false,
          ),
          _buildTimelineStep(
            'Completed',
            isCompleted ? DateFormat('MMM d, h:mm a').format(_order!.createdAt) : 'Pending',
            isCompleted,
            isCancelled,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep(String title, String subtitle, bool isDone, bool isCancelled, {required bool isLast}) {
    Color nodeColor = isCancelled ? AppColors.error : (isDone ? AppColors.primaryContainer : AppColors.surfaceVariant);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(color: nodeColor, shape: BoxShape.circle),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: nodeColor.withOpacity(isDone ? 1.0 : 0.5),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: isDone ? FontWeight.bold : FontWeight.normal, color: isCancelled ? AppColors.error : AppColors.onSurface)),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
              const SizedBox(height: 16),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildItemsList() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Items Ordered', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const Divider(height: 24),
          ..._order!.items.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.productName, style: const TextStyle(fontWeight: FontWeight.w600)),
                        Text('${item.quantity} x Rs. ${item.price}', style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  Text('Rs. ${(item.quantity * item.price).toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildFinancialSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFF7FAF3), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Financial Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const Divider(height: 24),
          _buildSummaryRow('Subtotal', 'Rs. ${_order!.totalAmount.toStringAsFixed(0)}'),
          const SizedBox(height: 8),
          _buildSummaryRow('Hub & Platform Fees', 'Rs. 20.00'),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Paid', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text('Rs. ${_order!.totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryContainer)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String title, String amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(color: AppColors.onSurfaceVariant)),
        Text(amount, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
