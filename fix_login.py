with open('lib/screens/auth/login_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Remove the _fillAdminCredentials method
method_start = content.find('  void _fillAdminCredentials() {')
method_end = content.find('  @override\n  Widget build(BuildContext context) {')
if method_start != -1 and method_end != -1:
    content = content[:method_start] + content[method_end:]

# 2. Remove the button UI
btn_start = content.find('                if (_selectedRoleTab == \'Admin\')')
btn_end = content.find('              ],\n            ),\n          ),\n        ),\n      ),\n    );\n  }\n}')
if btn_start != -1 and btn_end != -1:
    content = content[:btn_start] + content[btn_end:]

with open('lib/screens/auth/login_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
print("Removed dummy admin credentials button for production!")
