with open('lib/screens/customer/farmer_profile_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace("'Certified Organic Grower',", "widget.farmer['name'] ?? 'Fresh Produce',")
print("Replaced Certified Organic Grower")

with open('lib/screens/customer/farmer_profile_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
