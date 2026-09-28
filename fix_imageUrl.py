import re

with open('lib/screens/customer/order_detail_screen.dart', 'r', encoding='utf-8') as f:
    c = f.read()

c = c.replace(
    'image: DecorationImage(image: NetworkImage(item.imageUrl), fit: BoxFit.cover),',
    'image: item.imageUrl != null && item.imageUrl!.isNotEmpty ? DecorationImage(image: NetworkImage(item.imageUrl!), fit: BoxFit.cover) : null,'
)

with open('lib/screens/customer/order_detail_screen.dart', 'w', encoding='utf-8') as f:
    f.write(c)
