with open('lib/screens/customer/customer_home_screen.dart', 'r', encoding='utf-8') as f:
    c = f.read()

if 'firebase_auth.dart' not in c:
    c = c.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'package:firebase_auth/firebase_auth.dart';\nimport '../../providers/wishlist_provider.dart';")

# Handle AuthProvider collision
c = c.replace("import '../../providers/auth_provider.dart';", "import '../../providers/auth_provider.dart' as app_auth;")
c = c.replace("Provider.of<AuthProvider>(", "Provider.of<app_auth.AuthProvider>(")

# Strip emojis from strings
import re
def replace_garbage(match):
    return re.sub(r'[^\x00-\x7F]', '-', match.group(0))

c = re.sub(r"'[^']*'", replace_garbage, c)
c = re.sub(r'"[^"]*"', replace_garbage, c)

with open('lib/screens/customer/customer_home_screen.dart', 'w', encoding='utf-8') as f:
    f.write(c)
