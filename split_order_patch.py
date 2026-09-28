import re

with open('lib/services/database_service.dart', 'r', encoding='utf-8') as f:
    c = f.read()

# Replace placeOrder
old_place_order = r"Future<OrderModel> placeOrder\(\{.*?await orderRef\.set\(newOrder\.toMap\(\)\);\s*await sendNotification\(\s*userId:\s*customerId,\s*title:\s*\"Order Placed Successfully! \",\s*message:\s*\"Your order #\$\{newOrder\.id\.substring\(0,\s*6\)\} totaling \\\$\$\{totalAmount\.toStringAsFixed\(2\)\} has been placed\.\",\s*role:\s*\"customer\",\s*\);\s*return newOrder;\s*\}"

new_place_order = '''Future<void> placeOrder({
    required String customerId,
    required String customerName,
    required String customerPhone,
    required List<OrderItem> items,
    required double totalAmount,
    String? pickupSlotId,
    String? pickupSlotTime,
    String? marketId,
  }) async {
    for (var item in items) {
      DocumentSnapshot productDoc = await _productsRef.doc(item.productId).get();
      if (productDoc.exists) {
        double currentStock = (productDoc.get('quantity') ?? 0).toDouble();
        if (currentStock < item.quantity) {
          throw Exception("Insufficient stock for ${item.productName}. Available: $currentStock");
        }
      }
    }

    for (var item in items) {
      DocumentSnapshot productDoc = await _productsRef.doc(item.productId).get();
      if (productDoc.exists) {
        double currentStock = (productDoc.get('quantity') ?? 0).toDouble();
        double newStock = currentStock - item.quantity;
        await updateProductStock(item.productId, newStock < 0 ? 0 : newStock);
      }
    }

    Map<String, List<OrderItem>> groupedItems = {};
    for (var item in items) {
      String fId = item.farmerId.isNotEmpty ? item.farmerId : 'unknown_farmer';
      groupedItems.putIfAbsent(fId, () => []).add(item);
    }

    for (var entry in groupedItems.entries) {
      String farmerId = entry.key;
      List<OrderItem> farmerItems = entry.value;
      
      double farmerTotal = 0;
      for (var item in farmerItems) {
        farmerTotal += (item.price * item.quantity);
      }

      DocumentReference orderRef = _ordersRef.doc();
      OrderModel newOrder = OrderModel(
        id: orderRef.id,
        customerId: customerId,
        customerName: customerName,
        customerPhone: customerPhone,
        farmerId: farmerId,
        items: farmerItems,
        totalAmount: farmerTotal,
        pickupSlotId: pickupSlotId,
        pickupSlotTime: pickupSlotTime,
        marketId: marketId,
        status: 'Pending',
        paymentMethod: 'Simulated Cash on Pickup',
        createdAt: DateTime.now(),
      );
      await orderRef.set(newOrder.toMap());

      await sendNotification(
        userId: farmerId,
        title: "New Order Received!",
        message: "You have a new order #${newOrder.id.substring(0, 6)}.",
        role: "farmer",
      );
    }

    await sendNotification(
      userId: customerId,
      title: "Orders Placed Successfully!",
      message: "Your orders have been split by farmer and placed successfully.",
      role: "customer",
    );
  }'''

c = re.sub(old_place_order, new_place_order, c, flags=re.DOTALL)

with open('lib/services/database_service.dart', 'w', encoding='utf-8') as f:
    f.write(c)
