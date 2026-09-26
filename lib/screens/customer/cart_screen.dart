import 'package:flutter/material.dart';
import '../../core/auth_interceptor.dart';

import '../../core/dummy_data.dart';

import 'package:firebase_auth/firebase_auth.dart';

import '../auth/sign_in_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  int _selectedSlot = 0; // 0 for first slot, 1 for second

  void _removeFromCart(int index) {
    setState(() {
      DummyData.cart.removeAt(index);
    });
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Item removed from cart'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _updateQuantity(int index, int delta) {
    setState(() {
      int newQuantity = (DummyData.cart[index]['quantity'] as int) + delta;
      if (newQuantity > 0) {
        DummyData.cart[index]['quantity'] = newQuantity;
      }
    });
  }

  int get _itemsTotal {
    int total = 0;
    for (var item in DummyData.cart) {
      int price = int.tryParse(item['price'].toString()) ?? 0;
      int qty = item['quantity'] as int;
      total += (price * qty);
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF2E7D32);
    const Color darkText = Color(0xFF1F2937);
    const Color greyText = Color(0xFF6B7280);
    const Color background = Color(0xFFF9FBF9);

    int totalPayable = _itemsTotal > 0
        ? _itemsTotal + 20
        : 0; // Items + 20 Service Fee

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: darkText),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: primaryGreen,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.eco,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'HarvestHub',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: darkText,
                              height: 1.0,
                            ),
                          ),
                          Text(
                            'LOCAL FARM MARKETPLACE',
                            style: TextStyle(
                              fontSize: 6,
                              fontWeight: FontWeight.bold,
                              color: greyText,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Text(
                    'Cart...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: darkText,
                    ),
                  ),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: primaryGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Banner
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: primaryGreen,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.eco,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Harvested fresh today from local Sindh growers',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: primaryGreen,
                                    ),
                                  ),
                                  Text(
                                    'Zero storage transit • Handled with clean orga...',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: primaryGreen.withOpacity(0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.verified_outlined,
                              color: primaryGreen,
                              size: 20,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Items in Basket
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Items in Basket',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: darkText,
                            ),
                          ),
                          Text(
                            '${DummyData.cart.length} local items',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: primaryGreen,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      if (DummyData.cart.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.shopping_basket_outlined,
                                  size: 48,
                                  color: Colors.grey[300],
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Your basket is empty',
                                  style: TextStyle(color: greyText),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: DummyData.cart.length,
                          itemBuilder: (context, index) {
                            final item = DummyData.cart[index];
                            final int qty = item['quantity'] as int;
                            final int unitPrice =
                                int.tryParse(item['price'].toString()) ?? 0;
                            final int rowTotal = unitPrice * qty;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.02),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Image
                                  Stack(
                                    children: [
                                      Container(
                                        width: 72,
                                        height: 72,
                                        decoration: BoxDecoration(
                                          color:
                                              item['imageColor'] ??
                                              Colors.red[100],
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child:
                                              (item['imageUrl'] != null &&
                                                  item['imageUrl']
                                                      .toString()
                                                      .isNotEmpty)
                                              ? Image.network(
                                                  item['imageUrl'],
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                  height: double.infinity,
                                                )
                                              : Center(
                                                  child: Icon(
                                                    Icons.image,
                                                    color: Colors.black
                                                        .withOpacity(0.2),
                                                  ),
                                                ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 4,
                                        left: 4,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(
                                              0.9,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Row(
                                            children: const [
                                              Icon(
                                                Icons.eco_outlined,
                                                size: 8,
                                                color: primaryGreen,
                                              ),
                                              SizedBox(width: 2),
                                              Text(
                                                'Organic',
                                                style: TextStyle(
                                                  fontSize: 8,
                                                  color: primaryGreen,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                '${item['title']} (${item['unit']?.replaceAll('/', '')?.trim() ?? '1 kg'})',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: darkText,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () =>
                                                  _removeFromCart(index),
                                              child: const Icon(
                                                Icons.delete_outline,
                                                size: 20,
                                                color: greyText,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.local_shipping_outlined,
                                              size: 12,
                                              color: primaryGreen,
                                            ),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                'From ${item['farmerName']}',
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: greyText,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Rs. $rowTotal',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: 16,
                                                    color: primaryGreen,
                                                  ),
                                                ),
                                                if (qty > 1)
                                                  Text(
                                                    '(Rs. $unitPrice each)',
                                                    style: const TextStyle(
                                                      fontSize: 9,
                                                      color: greyText,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFF9FBF9),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: const Color(
                                                    0xFFE5E7EB,
                                                  ),
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  InkWell(
                                                    onTap: () =>
                                                        _updateQuantity(
                                                          index,
                                                          -1,
                                                        ),
                                                    child: const Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                            vertical: 4,
                                                          ),
                                                      child: Icon(
                                                        Icons.remove,
                                                        size: 16,
                                                        color: darkText,
                                                      ),
                                                    ),
                                                  ),
                                                  Text(
                                                    '$qty',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14,
                                                      color: darkText,
                                                    ),
                                                  ),
                                                  InkWell(
                                                    onTap: () =>
                                                        _updateQuantity(
                                                          index,
                                                          1,
                                                        ),
                                                    child: const Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                            vertical: 4,
                                                          ),
                                                      child: Icon(
                                                        Icons.add,
                                                        size: 16,
                                                        color: darkText,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                      const SizedBox(height: 24),

                      // Pickup Slot Selection
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
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
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF3F4F6),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.calendar_today_outlined,
                                        size: 16,
                                        color: primaryGreen,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Pickup Slot Selection',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: darkText,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE5E7EB),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'Today, Oct 24',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: darkText,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Available collection windows:',
                              style: TextStyle(fontSize: 12, color: greyText),
                            ),
                            const SizedBox(height: 12),

                            // Slot 1
                            GestureDetector(
                              onTap: () => setState(() => _selectedSlot = 0),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: _selectedSlot == 0
                                      ? const Color(0xFFE8F5E9)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _selectedSlot == 0
                                        ? primaryGreen.withOpacity(0.3)
                                        : Colors.transparent,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      _selectedSlot == 0
                                          ? Icons.check_circle
                                          : Icons.circle_outlined,
                                      color: _selectedSlot == 0
                                          ? primaryGreen
                                          : Colors.grey[300],
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            '5:30 PM — 6:00 PM',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: darkText,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Recommended • Farmer crates arrive by 5:15 PM',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: primaryGreen.withOpacity(
                                                0.8,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (_selectedSlot == 0)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: const Text(
                                          'SELECTED',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: darkText,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Slot 2
                            GestureDetector(
                              onTap: () => setState(() => _selectedSlot = 1),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: _selectedSlot == 1
                                      ? const Color(0xFFE8F5E9)
                                      : const Color(0xFFF9FBF9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      _selectedSlot == 1
                                          ? Icons.check_circle
                                          : Icons.circle_outlined,
                                      color: _selectedSlot == 1
                                          ? primaryGreen
                                          : Colors.grey[300],
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: const [
                                          Text(
                                            '6:00 PM — 6:30 PM',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: darkText,
                                            ),
                                          ),
                                          SizedBox(height: 2),
                                          Text(
                                            'Evening collection',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: greyText,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (_selectedSlot == 1)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: const Text(
                                          'SELECTED',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: darkText,
                                          ),
                                        ),
                                      )
                                    else
                                      const Text(
                                        'Open',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: greyText,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Location
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.location_on_outlined,
                                    size: 16,
                                    color: primaryGreen,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Karachi Farmers Market - Stall 14B & Hub Counter',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: darkText,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        const Text(
                                          'Plot 12-C, Khayaban-e-Seher, Phase 6, DHA, Karachi',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: greyText,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: const [
                                            Icon(
                                              Icons.directions_outlined,
                                              size: 12,
                                              color: primaryGreen,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              'Open in navigation map',
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: primaryGreen,
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
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Pickup Contact Details
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
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
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF3F4F6),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.contact_mail_outlined,
                                        size: 16,
                                        color: primaryGreen,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Pickup Contact Details',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: darkText,
                                      ),
                                    ),
                                  ],
                                ),
                                const Text(
                                  'Edit',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: primaryGreen,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: const [
                                Icon(
                                  Icons.person_outline,
                                  size: 18,
                                  color: darkText,
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Ubaid Rehman • +92 300 1234567',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: darkText,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.chat_bubble_outline,
                                  size: 18,
                                  color: darkText,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Pickup Contact: Notification will be sent via SMS when packed',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: darkText,
                                          height: 1.3,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: const [
                                          CircleAvatar(
                                            radius: 3,
                                            backgroundColor: primaryGreen,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            'SMS order PIN code will be required at counter',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: primaryGreen,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Bill Breakdown
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3F4F6),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.receipt_long_outlined,
                                    size: 16,
                                    color: primaryGreen,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Bill Breakdown',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: darkText,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Items Total',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: darkText,
                                  ),
                                ),
                                Text(
                                  'Rs. $_itemsTotal',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: darkText,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: const [
                                    Text(
                                      'Marketplace Service Fee',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: darkText,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Icon(
                                      Icons.info_outline,
                                      size: 12,
                                      color: greyText,
                                    ),
                                  ],
                                ),
                                const Text(
                                  'Rs. 20',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: darkText,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Farmer Packaging (Bio-Crates)',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: darkText,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F5E9),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'FREE',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: primaryGreen,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9FBF9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        'Total Payable at Pickup',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: darkText,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'Inclusive of all local hub surcharges',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: greyText,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    'Rs. $totalPayable',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      color: primaryGreen,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Guarantee Banner
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: primaryGreen,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.money,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Pay on Pickup Guaranteed',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: darkText,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'No advance online payment required. Pay farmer directly via Cash or QR upon collecting fresh produce.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: darkText,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 100), // Padding for bottom button
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // Sticky Bottom Button
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: DummyData.cart.isNotEmpty
          ? Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FBF9),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.9),
                    blurRadius: 20,
                    spreadRadius: 10,
                    offset: const Offset(0, -10),
                  ),
                ],
              ),
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    // Create an order
                    String itemsString = DummyData.cart
                        .map(
                          (item) =>
                              '${item['title']} (${item['quantity']} ${item['unit']?.replaceAll('/', '')?.trim() ?? ''})',
                        )
                        .join(', ');

                    final newOrder = {
                      'id':
                          '#ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                      'date': 'Today',
                      'status': 'Processing',
                      'items': itemsString,
                      'total': totalPayable.toString(),
                      'statusColor': const Color(0xFFFF9800),
                      'imageUrl':
                          DummyData.cart.isNotEmpty &&
                              DummyData.cart.first['imageUrl'] != null
                          ? DummyData.cart.first['imageUrl']
                          : 'https://images.unsplash.com/photo-1542838132-92c53300491e?q=80&w=200&auto=format&fit=crop',
                      'imageColor': DummyData.cart.isNotEmpty
                          ? DummyData.cart.first['imageColor']
                          : Colors.green[200],
                    };

                    // Update data without rebuilding the screen that is about to pop
                    DummyData.orders.insert(0, newOrder);
                    DummyData.cart.clear();

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Order Confirmed!')),
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.check_circle_outline, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Confirm Pickup Order',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '• Rs. $totalPayable',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : null,
    );
  }
}
