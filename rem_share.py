with open('lib/screens/customer/farmer_profile_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Remove share button in AppBar
content = content.replace('''          IconButton(
            icon: const Icon(Icons.share_outlined, color: darkText),
            onPressed: () {},
          ),''', '')

with open('lib/screens/customer/farmer_profile_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
print("Share removed")
