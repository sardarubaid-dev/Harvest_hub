import re

with open('lib/screens/customer/order_detail_screen.dart', 'r', encoding='utf-8') as f:
    c = f.read()

c = c.replace('_dbService.getFarmer(', '_dbService.getFarmerById(')

with open('lib/screens/customer/order_detail_screen.dart', 'w', encoding='utf-8') as f:
    f.write(c)
