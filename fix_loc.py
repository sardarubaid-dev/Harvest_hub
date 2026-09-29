with open('lib/screens/customer/farmer_profile_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

idx = content.find("2.4 km away")
if idx != -1:
    # Find the line it's on
    start_line = content.rfind("Text(", 0, idx)
    end_line = content.find("),", idx)
    content = content[:start_line] + "Text(widget.farmer['location'] ?? 'Pakistan', style: const TextStyle(fontSize: 13, color: darkText)" + content[end_line:]
    print("Fixed location")

with open('lib/screens/customer/farmer_profile_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
