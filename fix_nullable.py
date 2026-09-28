import re

with open('lib/screens/customer/order_detail_screen.dart', 'r', encoding='utf-8') as f:
    c = f.read()

c = c.replace('if (widget.order.farmerId.isNotEmpty) {', 'if (widget.order.farmerId?.isNotEmpty == true) {')
c = c.replace('_dbService.getFarmerById(widget.order.farmerId)', '_dbService.getFarmerById(widget.order.farmerId!)')
c = c.replace('_farmer!.profileImageUrl.isNotEmpty', '_farmer!.profileImageUrl?.isNotEmpty == true')
c = c.replace('NetworkImage(_farmer!.profileImageUrl)', 'NetworkImage(_farmer!.profileImageUrl!)')
c = c.replace('_farmer!.farmName.isNotEmpty', '_farmer!.farmName.isNotEmpty == true')
c = c.replace('_farmer!.name', "(_farmer!.farmName.isNotEmpty ? _farmer!.farmName : 'Farmer')")
c = c.replace('_farmer!.location.isNotEmpty', '_farmer!.location.isNotEmpty == true')
c = c.replace('NetworkImage(item.imageUrl)', 'NetworkImage(item.imageUrl)') # wait, OrderItem imageUrl is non-nullable?
c = c.replace('_farmer!.farmName.isNotEmpty == true ? _farmer!.farmName : (_farmer!.farmName.isNotEmpty ? _farmer!.farmName : \'Farmer\')', "_farmer!.farmName.isNotEmpty ? _farmer!.farmName : 'Farmer'")
# Just replacing `_farmer!.farmName.isNotEmpty ? _farmer!.farmName : _farmer!.name` entirely
c = re.sub(r"_farmer!\.farmName\.isNotEmpty\s*\?\s*_farmer!\.farmName\s*:\s*_farmer!\.name", "_farmer!.farmName.isNotEmpty ? _farmer!.farmName : 'Farmer'", c)

with open('lib/screens/customer/order_detail_screen.dart', 'w', encoding='utf-8') as f:
    f.write(c)
