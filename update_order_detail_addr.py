import re

with open('lib/screens/customer/order_detail_screen.dart', 'r', encoding='utf-8') as f:
    c = f.read()

# Add display for Delivery Address
old_slot = r"                      Text\('Pickup Slot: \$\{widget\.order\.pickupSlotTime \?\? \"Not Selected\"\}', style: const TextStyle\(fontWeight: FontWeight\.bold\)\),"
new_slot = '''                      Expanded(
                        child: Text(widget.order.deliveryAddress != null && widget.order.deliveryAddress!.isNotEmpty
                            ? 'Delivery Address: ${widget.order.deliveryAddress}'
                            : 'Pickup Slot: ${widget.order.pickupSlotTime ?? "Not Selected"}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                        ),
                      ),'''
c = re.sub(old_slot, new_slot, c)

with open('lib/screens/customer/order_detail_screen.dart', 'w', encoding='utf-8') as f:
    f.write(c)
