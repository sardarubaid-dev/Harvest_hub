with open('lib/services/database_service.dart', 'r', encoding='utf-8') as f:
    c = f.read()

c = c.replace('''    String? pickupSlotId,
    String? pickupSlotTime,
    String? marketId,
  }) async {''', '''    String? pickupSlotId,
    String? pickupSlotTime,
    String? marketId,
    String? deliveryAddress,
  }) async {''')

c = c.replace('''        pickupSlotTime: pickupSlotTime,
        marketId: marketId,
        status: 'Pending',
        paymentMethod: 'Simulated Cash on Pickup',''', '''        pickupSlotTime: pickupSlotTime,
        marketId: marketId,
        deliveryAddress: deliveryAddress,
        status: 'Pending',
        paymentMethod: deliveryAddress != null && deliveryAddress.isNotEmpty ? 'Cash on Delivery' : 'Simulated Cash on Pickup',''')

with open('lib/services/database_service.dart', 'w', encoding='utf-8') as f:
    f.write(c)
