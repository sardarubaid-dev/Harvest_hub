# -*- coding: utf-8 -*-
import re
with open('lib/screens/customer/farmer_profile_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

content = re.sub(r"const Text\(\n\s*'Spanning 15 acres.*?',\n\s*style: TextStyle\(\n\s*color: Color\(0xFF4B5563\),\n\s*fontSize: 14,\n\s*height: 1\.5,\n\s*\),\n\s*\)", '''Text(
                      (widget.farmer['specialty'] != null && widget.farmer['specialty'] != 'Fresh Local Produce' && widget.farmer['specialty'] != 'Fresh Regional Produce')
                          ? widget.farmer['specialty']
                          : 'This is a verified local farm partnering with HarvestHub to bring you fresh, quality produce directly from the fields.',
                      style: const TextStyle(
                        color: Color(0xFF4B5563),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    )''', content, flags=re.DOTALL)

with open('lib/screens/customer/farmer_profile_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
print("Done acres")
