# -*- coding: utf-8 -*-
import re
with open('lib/screens/customer/farmer_profile_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Replace Spanning 15 acres
content = re.sub(r"const Text\(\n\s*'Spanning 15 acres.*?market days\.',\n\s*style: TextStyle\(\n\s*fontSize: 14,\n\s*color: darkText,\n\s*height: 1\.5,\n\s*\),\n\s*\)", '''Text(
                      (widget.farmer['specialty'] != null && widget.farmer['specialty'] != 'Fresh Local Produce' && widget.farmer['specialty'] != 'Fresh Regional Produce')
                          ? widget.farmer['specialty']
                          : 'This is a verified local farm partnering with HarvestHub to bring you fresh, quality produce directly from the fields.',
                      style: const TextStyle(
                        fontSize: 14,
                        color: darkText,
                        height: 1.5,
                      ),
                    )''', content, flags=re.DOTALL)

with open('lib/screens/customer/farmer_profile_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
print("Done acres")
