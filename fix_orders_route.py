import re

with open('lib/screens/customer/orders_screen.dart', 'r', encoding='utf-8') as f:
    c = f.read()

# Add import if missing
if 'order_detail_screen.dart' not in c:
    c = c.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'order_detail_screen.dart';")

# Find the start of the item return
old_container = r"              return Container\(\n                margin: const EdgeInsets.only\(bottom: 16\),"
new_container = '''              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderDetailScreen(order: order),
                    ),
                  ).then((_) => setState(() {}));
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),'''

c = re.sub(old_container, new_container, c)

with open('lib/screens/customer/orders_screen.dart', 'w', encoding='utf-8') as f:
    f.write(c)
