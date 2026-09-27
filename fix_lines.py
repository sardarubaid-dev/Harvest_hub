import re

with open('c:/Users/Dr.pc/Desktop/harvest_hub/lib/screens/farmer/farmer_dashboard_tab.dart', 'r', encoding='utf-8') as f:
    lines = f.readlines()

new_lines = []
for line in lines:
    if 'ElevatedButton.icon(' in line:
        line = line.replace('ElevatedButton.icon(', 'ElevatedButton(')
    elif 'OutlinedButton.icon(' in line:
        line = line.replace('OutlinedButton.icon(', 'OutlinedButton(')
    elif 'icon: const Icon(' in line:
        line = line.replace('icon: const Icon', 'child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon')
    elif 'label: const Text(' in line:
        line = line.replace('label: const Text', 'const SizedBox(width: 8), const Text')
        line = line.replace('),', '],),')
    new_lines.append(line)

with open('c:/Users/Dr.pc/Desktop/harvest_hub/lib/screens/farmer/farmer_dashboard_tab.dart', 'w', encoding='utf-8') as f:
    f.writelines(new_lines)