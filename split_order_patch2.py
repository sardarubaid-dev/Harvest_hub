with open('lib/services/database_service.dart', 'r', encoding='utf-8') as f:
    c = f.read()

import re

# Find the start of placeOrder
start_idx = c.find('Future<OrderModel> placeOrder({')
if start_idx == -1:
    print("Could not find start of placeOrder")
else:
    # Find the end of the method by counting braces
    open_braces = 0
    end_idx = -1
    for i in range(start_idx, len(c)):
        if c[i] == '{':
            open_braces += 1
        elif c[i] == '}':
            open_braces -= 1
            if open_braces == 0:
                end_idx = i + 1
                break
    
    if end_idx != -1:
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
        c = c[:start_idx] + new_place_order + c[end_idx:]
        
        with open('lib/services/database_service.dart', 'w', encoding='utf-8') as f:
            f.write(c)
        print("Replaced successfully")
    else:
        print("Could not find end of placeOrder")
