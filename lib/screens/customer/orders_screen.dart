import 'package:flutter/material.dart';
import '../../core/dummy_data.dart';

class OrdersScreen extends StatelessWidget {
  final VoidCallback onShopNow;

  const OrdersScreen({Key? key, required this.onShopNow}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF2E7D32);
    const Color darkText = Color(0xFF1F2937);
    const Color greyText = Color(0xFF6B7280);
    const Color background = Color(0xFFF9FBF9);

    final orders = DummyData.orders;

    return Scaffold(
      backgroundColor: background,
      body: orders.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.receipt_long_outlined, size: 64, color: primaryGreen),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'No Orders Yet',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: darkText),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'You haven\'t placed any orders. Start exploring fresh local produce and support your regional farmers!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: greyText, height: 1.5),
                    ),
                    const SizedBox(height: 32),
                    GestureDetector(
                      onTap: onShopNow,
                      child: Container(
                        width: double.infinity,
                        height: 52,
                        decoration: BoxDecoration(
                          color: primaryGreen,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'Start Shopping',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                try {
                  final order = orders[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16.0),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(order['id']?.toString() ?? '#ORD', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: darkText)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: (order['statusColor'] is Color ? order['statusColor'] as Color : Colors.grey).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                order['status']?.toString() ?? 'Pending',
                                style: TextStyle(color: (order['statusColor'] is Color ? order['statusColor'] as Color : Colors.grey), fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Placed on: ${order['date'] ?? 'Today'}', style: const TextStyle(color: greyText, fontSize: 13)),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          child: Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (order['imageUrl'] != null && order['imageUrl'].toString().isNotEmpty)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  order['imageUrl'].toString(),
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: (order['imageColor'] is Color) ? order['imageColor'] : const Color(0xFFF3F4F6),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(Icons.shopping_bag, color: Colors.white.withOpacity(0.8), size: 24),
                                  ),
                                ),
                              )
                            else
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: (order['imageColor'] is Color) ? order['imageColor'] : const Color(0xFFF3F4F6),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.shopping_bag, color: Colors.white.withOpacity(0.8), size: 24),
                              ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Items', style: TextStyle(fontSize: 12, color: greyText)),
                                  const SizedBox(height: 4),
                                  Text(order['items']?.toString() ?? '', style: const TextStyle(fontSize: 13, color: darkText, height: 1.4)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          child: Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Total Amount', style: TextStyle(fontSize: 12, color: greyText)),
                                const SizedBox(height: 2),
                                Text('Rs. ${order['total'] ?? '0'}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryGreen)),
                              ],
                            ),
                            GestureDetector(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Viewing details for ${order['id']}')));
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'View Details',
                                  style: TextStyle(
                                    color: Color(0xFF2E7D32),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                } catch (e) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    color: Colors.red[100],
                    child: Text('Error rendering order: $e', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  );
                }
              },
            ),
    );
  }
}


