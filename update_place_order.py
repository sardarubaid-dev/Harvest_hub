import re

with open('lib/services/database_service.dart', 'r', encoding='utf-8') as f:
    c = f.read()

# Update signature
old_sig = r"String\? pickupSlotTime,\s*String\? marketId,\s*\}) async \{"
new_sig = "String? pickupSlotTime,\n    String? marketId,\n    String? deliveryAddress,\n  }) async {"
c = re.sub(old_sig, new_sig, c)

# Update OrderModel instantiation
old_inst = r"pickupSlotTime: pickupSlotTime,\s*marketId: marketId,\s*status: 'Pending',\s*paymentMethod: 'Simulated Cash on Pickup',"
new_inst = "pickupSlotTime: pickupSlotTime,\n        marketId: marketId,\n        deliveryAddress: deliveryAddress,\n        status: 'Pending',\n        paymentMethod: deliveryAddress != null ? 'Cash on Delivery' : 'Simulated Cash on Pickup',"
c = re.sub(old_inst, new_inst, c)

with open('lib/services/database_service.dart', 'w', encoding='utf-8') as f:
    f.write(c)
