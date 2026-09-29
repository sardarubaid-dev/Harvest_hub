import re

# Fix sign_in_screen.dart
with open('lib/screens/auth/sign_in_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace("'e.g. ubaid@example.com'", "'email@example.com'")
content = content.replace("'........'", "'Enter password'")

start_idx = content.find('const SizedBox(height: 32),\n\n              Container(\n                padding: const EdgeInsets.all(16),')
end_idx = content.find('            ],\n          ),\n        ),\n      ),\n    );\n  }\n}')

if start_idx != -1 and end_idx != -1:
    content = content[:start_idx] + content[end_idx:]

with open('lib/screens/auth/sign_in_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)


# Fix role_selection_screen.dart
with open('lib/screens/role_selection_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

start_idx = content.find('              // Footer\n              Row(')
end_idx = content.find('              const SizedBox(height: 20),\n            ],\n          ),\n        ),\n      ),\n    );\n  }')
if start_idx != -1 and end_idx != -1:
    content = content[:start_idx] + content[end_idx:]

with open('lib/screens/role_selection_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)


# Fix register_customer_screen.dart
with open('lib/screens/auth/register_customer_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

def remove_emojis(text):
    return "".join(c if ord(c) < 127 else "-" for c in text)

content_lines = content.split("\n")
for i in range(len(content_lines)):
    if "FRESH" in content_lines[i] or "Free registration" in content_lines[i]:
        content_lines[i] = remove_emojis(content_lines[i])

with open('lib/screens/auth/register_customer_screen.dart', 'w', encoding='utf-8') as f:
    f.write("\n".join(content_lines))

print("Fixed auth screens")
