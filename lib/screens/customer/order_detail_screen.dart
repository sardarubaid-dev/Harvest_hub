import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/order_model.dart';
import '../../models/farmer_model.dart';
import '../../services/database_service.dart';

class OrderDetailScreen extends StatefulWidget {
  final OrderModel order;
  const OrderDetailScreen({Key? key, required this.order}) : super(key: key);

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final DatabaseService _dbService = DatabaseService();
  bool _isCancelling = false;
  FarmerModel? _farmer;

  @override
  void initState() {
    super.initState();
    _fetchFarmerDetails();
  }

  Future<void> _fetchFarmerDetails() async {
    if (widget.order.farmerId?.isNotEmpty == true) {
      final farmerDoc = await _dbService.getFarmerById(widget.order.farmerId!);
      if (mounted) {
        setState(() {
          _farmer = farmerDoc;
        });
      }
    }
  }

  Future<void> _cancelOrder() async {
    setState(() => _isCancelling = true);
    try {
      await _dbService.updateOrderStatus(widget.order.id, 'Cancelled');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking Cancelled Successfully'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to cancel: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _isCancelling = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF2E7D32);
    final isPending = widget.order.status.toLowerCase() == 'pending';

    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF9),
      appBar: AppBar(
        title: const Text('Order Details', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status and ID
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Order #${widget.order.id.substring(0, 8).toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isPending ? Colors.orange.withOpacity(0.1) : (widget.order.status.toLowerCase() == 'cancelled' ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1)),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.order.status,
                          style: TextStyle(
                            color: isPending ? Colors.orange : (widget.order.status.toLowerCase() == 'cancelled' ? Colors.red : Colors.green),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Placed on: ${DateFormat('dd MMM yyyy, hh:mm a').format(widget.order.createdAt)}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  const Divider(height: 24),
                  Row(
                    children: [
                      const Icon(Icons.access_time, color: primaryGreen, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(widget.order.deliveryAddress != null && widget.order.deliveryAddress!.isNotEmpty
                            ? 'Delivery Address: ${widget.order.deliveryAddress}'
                            : 'Pickup Slot: ${widget.order.pickupSlotTime ?? "Not Selected"}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Farmer Info
            if (_farmer != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: _farmer!.profileImageUrl?.isNotEmpty == true ? NetworkImage(_farmer!.profileImageUrl!) : null,
                      child: (_farmer!.profileImageUrl?.isEmpty ?? true) ? const Icon(Icons.store) : null,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Farmer: ${_farmer!.farmName.isNotEmpty ? _farmer!.farmName : 'Farmer'}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text(_farmer!.location.isNotEmpty == true ? _farmer!.location : 'Local Farm', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            // Items
            const Text('Purchased Products', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              clipBehavior: Clip.antiAlias,
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.order.items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = widget.order.items[index];
                  return ListTile(
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: item.imageUrl != null && item.imageUrl!.isNotEmpty ? DecorationImage(image: NetworkImage(item.imageUrl!), fit: BoxFit.cover) : null,
                      ),
                    ),
                    title: Text(item.productName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text('${item.quantity} ${item.unit} x Rs. ${item.price.toInt()}'),
                    trailing: Text('Rs. ${(item.quantity * item.price).toInt()}', style: const TextStyle(fontWeight: FontWeight.bold, color: primaryGreen)),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Total
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Amount', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('Rs. ${widget.order.totalAmount.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: primaryGreen)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Cancel Button
            if (isPending)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isCancelling ? null : _cancelOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade50,
                    foregroundColor: Colors.red,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isCancelling 
                      ? const CircularProgressIndicator()
                      : const Text('Cancel Booking', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
