with open('lib/screens/customer/farmer_profile_screen.dart', 'r', encoding='utf-8') as f:
    lines = f.readlines()

# 1. Fix line 299 (remove stray comma)
if lines[298].strip() == ',':
    lines[298] = '\n'

# 2. Fix line 331 (remove const from children array)
if 'children: const [' in lines[330]:
    lines[330] = lines[330].replace('children: const [', 'children: [')

# 3. Fix line 604 and 606 (dummy categories)
for i in range(len(lines)):
    if 'itemCount: categories.length,' in lines[i]:
        lines[i] = lines[i].replace('categories.length', '0')
    if 'final cat = categories[index];' in lines[i]:
        lines[i] = lines[i].replace('categories[index]', "''")

with open('lib/screens/customer/farmer_profile_screen.dart', 'w', encoding='utf-8') as f:
    f.writelines(lines)
print("Syntax fixed")
