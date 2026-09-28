import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  String _deliveryType = 'Delivery'; // 'Delivery' or 'Pickup'

  @override
  void initState() {
    super.initState();
    _prefillAddress();
  }

  @override
  void dispose() {
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

  Future<void> _handleConfirmOrder() async {
    if (_deliveryType == 'Delivery' && _addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a delivery address'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
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
          productId: item['productId'] ?? item['id'] ?? '',
          farmerId: item['farmerId'] ?? '',
          productName: item['name'] ?? item['title'] ?? 'Unknown Item',
          price: price,
          quantity: qty,
          unit: item['unit'] ?? 'kg',
          imageUrl: item['imageUrl'],
        );
      }).toList();

      // Total with shipping logic
      double finalTotal = widget.totalAmount.toDouble();
      if (_deliveryType == 'Delivery') {
        finalTotal += 150.0; // standard delivery fee
      }

      await _dbService.placeOrder(
        customerId: customerId,
        customerName: customerName,
        customerPhone: customerPhone,
        items: items,
        totalAmount: finalTotal,
        pickupSlotId: null,
        pickupSlotTime: null,
        marketId: null, // Bypassed
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
          backgroundColor: Color(0xFF2E7D32),
          behavior: SnackBarBehavior.floating,
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
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF2E7D32);
    const Color darkText = Color(0xFF191D19);
    const Color greyText = Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F4),
      appBar: AppBar(
        title: const Text('Checkout', style: TextStyle(color: darkText, fontWeight: FontWeight.w900, fontSize: 22)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: darkText),
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Delivery Option Toggle
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _deliveryType = 'Delivery'),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _deliveryType == 'Delivery' ? primaryGreen : Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 6,
                              children: [
                                Icon(Icons.local_shipping, size: 18, color: _deliveryType == 'Delivery' ? Colors.white : greyText),
                                Text(
                                  'Delivery',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: _deliveryType == 'Delivery' ? Colors.white : greyText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _deliveryType = 'Pickup'),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _deliveryType == 'Pickup' ? primaryGreen : Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 6,
                              children: [
                                Icon(Icons.storefront, size: 18, color: _deliveryType == 'Pickup' ? Colors.white : greyText),
                                Text(
                                  'Farm Pickup',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: _deliveryType == 'Pickup' ? Colors.white : greyText,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Dynamic Section based on selection
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _deliveryType == 'Delivery' ? _buildDeliverySection(primaryGreen) : _buildPickupSection(primaryGreen),
                ),

                const SizedBox(height: 32),

                // Order Summary Receipt
                const Text('Order Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: darkText)),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8)),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          color: Colors.white,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...widget.cartItems.map((item) {
                                final int qty = (item['quantity'] is num) ? (item['quantity'] as num).toInt() : 1;
                                final int unitPrice = (double.tryParse(item['price']?.toString().replaceAll(RegExp(r'[^0-9.]'), '') ?? '0') ?? 0.0).toInt();
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(color: const Color(0xFFF4F7F4), borderRadius: BorderRadius.circular(8)),
                                        alignment: Alignment.center,
                                        child: Text('${qty}x', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF40493D))),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(item['name'] ?? item['title'] ?? 'Item', style: const TextStyle(color: darkText, fontWeight: FontWeight.bold, fontSize: 15)),
                                            Text(item['farmerName'] ?? 'Farm', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                                          ],
                                        ),
                                      ),
                                      Text('Rs. ${unitPrice * qty}', style: const TextStyle(color: darkText, fontWeight: FontWeight.w900, fontSize: 15)),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                        // Dashed divider
                        Row(
                          children: List.generate(
                            30,
                            (index) => Expanded(
                              child: Container(
                                height: 1.5,
                                color: index % 2 == 0 ? Colors.grey.shade300 : Colors.transparent,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF9FBF9),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Subtotal', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                                  Text('Rs. ${widget.totalAmount}', style: const TextStyle(color: darkText, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Delivery Fee', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                                  Text(_deliveryType == 'Delivery' ? 'Rs. 150' : 'Free', style: TextStyle(color: _deliveryType == 'Delivery' ? darkText : primaryGreen, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Total Amount', style: TextStyle(color: darkText, fontWeight: FontWeight.w900, fontSize: 18)),
                                  Text('Rs. ${widget.totalAmount + (_deliveryType == 'Delivery' ? 150 : 0)}', style: TextStyle(color: primaryGreen, fontWeight: FontWeight.w900, fontSize: 22)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Fixed Bottom Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _handleConfirmOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 5,
                    shadowColor: primaryGreen.withOpacity(0.5),
                  ),
                  child: _isProcessing
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Confirm Order', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward_rounded, size: 20),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliverySection(Color primaryGreen) {
    return Column(
      key: const ValueKey('Delivery'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Delivery Address', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF191D19))),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: TextField(
            controller: _addressController,
            maxLines: 3,
            style: const TextStyle(fontSize: 15, height: 1.4),
            decoration: InputDecoration(
              hintText: 'Enter your complete house/apartment address...',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              prefixIcon: const Padding(
                padding: EdgeInsets.only(bottom: 40),
                child: Icon(Icons.location_on, color: Color(0xFF388E3C)),
              ),
              filled: true,
              fillColor: Colors.transparent,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPickupSection(Color primaryGreen) {
    return Container(
      key: const ValueKey('Pickup'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFE8F5E9), Color(0xFFF1F8F1)]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFC8E6C9), width: 1.5),
        boxShadow: [BoxShadow(color: const Color(0x0F2E7D32), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: Icon(Icons.maps_home_work, color: primaryGreen, size: 24),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text('Farm Gate Pickup', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF191D19))),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Skip the delivery fee! You can pick up your fresh order directly from the farmer. Farm location and contact details will be shared on the order confirmation screen.',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade800, height: 1.4),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Icon(Icons.info_outline, color: primaryGreen, size: 16),
                const SizedBox(width: 8),
                const Expanded(child: Text('Available 9:00 AM - 6:00 PM', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)), overflow: TextOverflow.ellipsis)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
