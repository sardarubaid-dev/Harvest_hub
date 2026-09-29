import re
with open('lib/screens/customer/farmer_profile_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace("'14 Fresh Batches'", "'Farm Products'")

with open('lib/screens/customer/farmer_profile_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
print("Replaced 14 Fresh Batches")
