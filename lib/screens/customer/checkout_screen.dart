import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../../models/market_model.dart';
import '../../models/pickup_slot_model.dart';
import '../../models/order_model.dart';
import '../../providers/auth_provider.dart' as app_auth;
import '../../providers/cart_provider.dart';
import '../../services/database_service.dart';

class CheckoutScreen extends StatefulWidget {
  final List<dynamic> cartItems;
  final int totalAmount;

  const CheckoutScreen({
    Key? key,
    required this.cartItems,
    required this.totalAmount,
  }) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final DatabaseService _dbService = DatabaseService();
  final TextEditingController _addressController = TextEditingController();

  bool _isProcessing = false;
  String _deliveryType = 'Delivery';

  List<MarketModel> _markets = [];
  List<PickupSlotModel> _pickupSlots = [];
  PickupSlotModel? _selectedSlot;
  StreamSubscription? _marketsSub;
  StreamSubscription? _slotsSub;

  @override
  void initState() {
    super.initState();
    _prefillAddress();
    _subscribeToMarkets();
  }

  @override
  void dispose() {
    _marketsSub?.cancel();
    _slotsSub?.cancel();
    _addressController.dispose();
    super.dispose();
  }

  void _prefillAddress() {
    final authProv = Provider.of<app_auth.AuthProvider>(context, listen: false);
    final addr = authProv.currentCustomer?.address ?? '';
    if (addr.isNotEmpty) {
      _addressController.text = addr;
    }
  }

  void _subscribeToMarkets() {
    _marketsSub = _dbService.streamMarkets().listen((markets) {
      if (!mounted) return;
      setState(() => _markets = markets);
      if (markets.isNotEmpty) {
        _slotsSub?.cancel();
        _slotsSub = _dbService
            .streamPickupSlots(marketId: markets.first.id)
            .listen((slots) {
          if (!mounted) return;
          setState(() {
            _pickupSlots = slots;
            if (!slots.any((s) => s.id == _selectedSlot?.id)) {
              _selectedSlot = null;
            }
          });
        });
      }
    });
  }

  Future<void> _handleConfirmOrder() async {
    if (_deliveryType == 'Delivery' && _addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a delivery address'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_deliveryType == 'Pickup' && _selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a pickup slot'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final authProv = Provider.of<app_auth.AuthProvider>(context, listen: false);
      final customer = authProv.currentCustomer;
      final user = authProv.currentUser;

      final String customerId = user?.uid ?? '';
      final String customerName = customer?.name ?? user?.email ?? 'Guest';
      final String customerPhone = customer?.phone ?? '';

      final List<OrderItem> items = widget.cartItems.map((item) {
        final double price = double.tryParse(
                item['price']?.toString().replaceAll(RegExp(r'[^0-9.]'), '') ??
                    '0') ??
            0.0;
        final double qty =
            (item['quantity'] is num) ? (item['quantity'] as num).toDouble() : 1.0;

        return OrderItem(
          productId: item['productId'] ?? '',
          farmerId: item['farmerId'] ?? '',
          productName: item['name'] ?? 'Unknown Item',
          price: price,
          quantity: qty,
          unit: item['unit'] ?? 'kg',
          imageUrl: item['imageUrl'],
        );
      }).toList();

      await _dbService.placeOrder(
        customerId: customerId,
        customerName: customerName,
        customerPhone: customerPhone,
        items: items,
        totalAmount: widget.totalAmount.toDouble(),
        pickupSlotId: _deliveryType == 'Pickup' ? _selectedSlot?.id : null,
        pickupSlotTime:
            _deliveryType == 'Pickup' ? _selectedSlot?.startTime : null,
        marketId: (_deliveryType == 'Pickup' && _markets.isNotEmpty)
            ? _markets.first.id
            : null,
        deliveryAddress:
            _deliveryType == 'Delivery' ? _addressController.text.trim() : null,
      );

      // Clear the cart
      if (mounted) {
        final cartProv = Provider.of<CartProvider>(context, listen: false);
        await cartProv.clearCart();
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order Placed Successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Pop back to home
      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF2E7D32);
    const Color darkText = Color(0xFF1F2937);
    const Color greyText = Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF9),
      appBar: AppBar(
        title: const Text('Checkout',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Delivery Method Toggle ---
            const Text('Delivery Method',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkText)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _DeliveryTypeCard(
                    label: 'Home Delivery',
                    icon: Icons.delivery_dining,
                    isSelected: _deliveryType == 'Delivery',
                    onTap: () => setState(() => _deliveryType = 'Delivery'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DeliveryTypeCard(
                    label: 'Self Pickup',
                    icon: Icons.store,
                    isSelected: _deliveryType == 'Pickup',
                    onTap: () => setState(() => _deliveryType = 'Pickup'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // --- Conditional Section ---
            if (_deliveryType == 'Delivery') ...[
              const Text('Delivery Address',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkText)),
              const SizedBox(height: 12),
              TextField(
                controller: _addressController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Enter your complete delivery address...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ] else ...[
              const Text('Select Pickup Slot',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkText)),
              const SizedBox(height: 12),
              if (_pickupSlots.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('No pickup slots available at the moment.',
                      style: TextStyle(color: greyText)),
                )
              else
                ...(_pickupSlots.map((slot) {
                  final isSelected = _selectedSlot?.id == slot.id;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedSlot = slot),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? primaryGreen.withOpacity(0.06)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? primaryGreen : Colors.grey.shade200,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.access_time,
                              color: isSelected ? primaryGreen : greyText),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '${slot.startTime} - ${slot.endTime}',
                              style: TextStyle(
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected ? primaryGreen : darkText,
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_circle,
                                color: primaryGreen, size: 20),
                        ],
                      ),
                    ),
                  );
                }).toList()),
            ],

            const SizedBox(height: 32),

            // --- Order Items Summary ---
            const Text('Order Summary',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkText)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  ...widget.cartItems.map((item) {
                    final int qty = (item['quantity'] is num)
                        ? (item['quantity'] as num).toInt()
                        : 1;
                    final int unitPrice = (double.tryParse(item['price']
                                    ?.toString()
                                    .replaceAll(RegExp(r'[^0-9.]'), '') ??
                                '0') ??
                            0.0)
                        .toInt();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${item['name'] ?? 'Item'} x$qty',
                              style: const TextStyle(color: darkText),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            'Rs. ${unitPrice * qty}',
                            style: const TextStyle(
                                color: darkText, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: darkText)),
                      Text(
                        'Rs. ${widget.totalAmount}',
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryGreen),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // --- Place Order Button ---
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _handleConfirmOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: _isProcessing
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Place Order',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _DeliveryTypeCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _DeliveryTypeCard({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF2E7D32);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? primaryGreen : Colors.white,
          border: Border.all(
              color: isSelected ? primaryGreen : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon,
                color: isSelected ? Colors.white : Colors.grey.shade600,
                size: 28),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
