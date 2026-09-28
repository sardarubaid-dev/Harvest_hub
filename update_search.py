import sys

file_path = r'c:\Users\Dr.pc\Desktop\harvest_hub\lib\screens\customer\search_filter_screen.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

import re
old_text = r'''        final matchesCat = p.categoryName.toLowerCase().contains(q);
        return matchesName || matchesDesc || matchesFarmer || matchesCat;'''

new_text = '''        final matchesCat = p.categoryName.toLowerCase().contains(q);
        final matchesMarket = (p.marketName ?? '').toLowerCase().contains(q);
        return matchesName || matchesDesc || matchesFarmer || matchesCat || matchesMarket;'''

content = re.sub(old_text, new_text, content)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)
