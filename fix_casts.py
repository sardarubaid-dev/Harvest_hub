import re
with open('lib/screens/customer/customer_home_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace(
    "double qA = (a['quantity'] ?? 0.0) as double;",
    "double qA = (a['quantity'] as num?)?.toDouble() ?? 0.0;"
).replace(
    "double qB = (b['quantity'] ?? 0.0) as double;",
    "double qB = (b['quantity'] as num?)?.toDouble() ?? 0.0;"
)

with open('lib/screens/customer/customer_home_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
print("Fixed casts")
