import re
with open('lib/screens/customer/farmer_profile_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

pattern = r"SizedBox\(\n\s*height: 36,\n\s*child: ListView\.builder\([\s\S]*?\}\n\s*\),\n\s*\)"
content = re.sub(pattern, "const SizedBox.shrink()", content)

with open('lib/screens/customer/farmer_profile_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
print("Done")
