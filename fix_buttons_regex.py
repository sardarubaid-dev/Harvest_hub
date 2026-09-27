import re

with open('c:/Users/Dr.pc/Desktop/harvest_hub/lib/screens/farmer/farmer_dashboard_tab.dart', 'r', encoding='utf-8') as f:
    text = f.read()

text = re.sub(
    r"ElevatedButton\.icon\(\s*onPressed: ([^,]+),\s*icon: ([^,]+),\s*label: ([^,]+),\s*style: ([^)]+\)),\s*\)",
    r"ElevatedButton(onPressed: \1, style: \4, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [\2, const SizedBox(width: 8), \3],),)",
    text
)

text = re.sub(
    r"OutlinedButton\.icon\(\s*onPressed: ([^,]+),\s*icon: ([^,]+(?>,\s*color:\s*[^)]+)?\)),\s*label: ([^,]+(?>,\s*style:\s*[^)]+\))?),\s*style: ([^)]+\)),\s*\)",
    r"OutlinedButton(onPressed: \1, style: \4, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [\2, const SizedBox(width: 8), \3],),)",
    text
)

with open('c:/Users/Dr.pc/Desktop/harvest_hub/lib/screens/farmer/farmer_dashboard_tab.dart', 'w', encoding='utf-8') as f:
    f.write(text)