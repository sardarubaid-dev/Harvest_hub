with open('lib/screens/customer/category_products_screen.dart', 'r', encoding='utf-8') as f:
    c = f.read()

# I need to add import 'cart_screen.dart'; if it's not there.
if 'cart_screen.dart' not in c:
    c = c.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'cart_screen.dart';")

# Replace pushNamed with MaterialPageRoute
old_nav = "Navigator.pushNamed(context, '/cart');"
new_nav = "Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));"

c = c.replace(old_nav, new_nav)

with open('lib/screens/customer/category_products_screen.dart', 'w', encoding='utf-8') as f:
    f.write(c)
