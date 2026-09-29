with open('lib/screens/customer/farmer_profile_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace("import 'package:provider/provider.dart';", "import 'package:provider/provider.dart';\nimport '../../providers/auth_provider.dart' as app_auth;")

with open('lib/screens/customer/farmer_profile_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
print("Done")
