import re

with open('c:/Users/Dr.pc/Desktop/harvest_hub/lib/screens/farmer/farmer_dashboard_tab.dart', 'r', encoding='utf-8') as f:
    text = f.read()

# Replace const Expanded(
text = text.replace('const Expanded(', 'Expanded(')

# Replace ElevatedButton.icon with ElevatedButton and Row
text = re.sub(
    r"ElevatedButton\.icon\(\s*onPressed:\s*\(\)\s*\{\},\s*icon:\s*const Icon\(([^,]+),\s*size:\s*([^)]+)\),\s*label:\s*const Text\('([^']+)'\),\s*style:\s*ElevatedButton\.styleFrom\(([^)]+)\),\s*\)",
    r"ElevatedButton(\n                      onPressed: () {},\n                      style: ElevatedButton.styleFrom(\4),\n                      child: Row(\n                        mainAxisAlignment: MainAxisAlignment.center,\n                        children: const [\n                          Icon(\1, size: \2),\n                          SizedBox(width: 8),\n                          Text('\3'),\n                        ],\n                      ),\n                    )",
    text
)

# Replace OutlinedButton.icon
text = re.sub(
    r"OutlinedButton\.icon\(\s*onPressed:\s*\(\)\s*\{\},\s*icon:\s*const Icon\(([^,]+),\s*size:\s*([^,]+),\s*color:\s*([^)]+)\),\s*label:\s*const Text\('([^']+)',\s*style:\s*TextStyle\(color:\s*([^)]+)\)\),\s*style:\s*OutlinedButton\.styleFrom\(([^)]+)\),\s*\)",
    r"OutlinedButton(\n                      onPressed: () {},\n                      style: OutlinedButton.styleFrom(\6),\n                      child: Row(\n                        mainAxisAlignment: MainAxisAlignment.center,\n                        children: const [\n                          Icon(\1, size: \2, color: \3),\n                          SizedBox(width: 8),\n                          Text('\4', style: TextStyle(color: \5)),\n                        ],\n                      ),\n                    )",
    text
)

with open('c:/Users/Dr.pc/Desktop/harvest_hub/lib/screens/farmer/farmer_dashboard_tab.dart', 'w', encoding='utf-8') as f:
    f.write(text)