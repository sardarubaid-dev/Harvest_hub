import re
with open('lib/screens/customer/farmer_profile_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Remove the slot Container (Next Harvest Drop)
# It's inside a Container with color: const Color(0xFFE8F5E9)
start_str = "Container(\n                    padding: const EdgeInsets.all(16),\n                    decoration: BoxDecoration(\n                      color: const Color(0xFFE8F5E9),"
idx = content.find(start_str)
if idx != -1:
    end_idx = content.find('NEXT HARVEST DROP', idx)
    end_idx = content.find('),', content.find(']', end_idx))
    end_idx = content.find('),', end_idx+1)
    end_idx = content.find(',', end_idx+1)
    content = content[:idx] + 'const SizedBox.shrink(),' + content[end_idx+1:]
    print("Removed slot container")
else:
    print("Slot container not found")

with open('lib/screens/customer/farmer_profile_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
