import re
with open('c:/Users/Dr.pc/Desktop/harvest_hub/lib/screens/farmer/farmer_dashboard_tab.dart', 'r', encoding='utf-8') as f:
    text = f.read()

text = re.sub(r"SizedBox\(\s*height:\s*24,\s*child:\s*Switch\(", "Switch(", text)
text = re.sub(r"activeTrackColor: Color\(0xFF2E7D32\),\s*\),\s*\),", r"activeTrackColor: Color(0xFF2E7D32),),", text)

with open('c:/Users/Dr.pc/Desktop/harvest_hub/lib/screens/farmer/farmer_dashboard_tab.dart', 'w', encoding='utf-8') as f:
    f.write(text)