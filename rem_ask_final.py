with open('lib/screens/customer/farmer_profile_screen.dart', 'r', encoding='utf-8') as f:
    lines = f.readlines()

for i in range(266, 298):
    lines[i] = ""

with open('lib/screens/customer/farmer_profile_screen.dart', 'w', encoding='utf-8') as f:
    f.writelines(lines)
print("Removed Ask")
