import re

with open('c:/Users/Dr.pc/Desktop/harvest_hub/lib/screens/farmer/farmer_dashboard_tab.dart', 'r', encoding='utf-8') as f:
    text = f.read()

# Aggressively remove 'const ' keyword everywhere except where absolutely necessary (like const EdgeInsets).
# Actually, it's easier to just strip 'const [' to '[' and 'const Text' to 'Text' and 'const Icon' to 'Icon' and 'const SizedBox' to 'SizedBox' and 'const Spacer' to 'Spacer' and 'const CircleAvatar' to 'CircleAvatar'.

text = text.replace('const [', '[')
text = text.replace('const Text', 'Text')
text = text.replace('const Icon', 'Icon')
text = text.replace('const SizedBox', 'SizedBox')
text = text.replace('const Spacer', 'Spacer')
text = text.replace('const CircleAvatar', 'CircleAvatar')
text = text.replace('const Expanded', 'Expanded')
text = text.replace('const Color', 'Color')
text = text.replace('const TextStyle', 'TextStyle')

with open('c:/Users/Dr.pc/Desktop/harvest_hub/lib/screens/farmer/farmer_dashboard_tab.dart', 'w', encoding='utf-8') as f:
    f.write(text)