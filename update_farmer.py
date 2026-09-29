import re

with open('lib/screens/customer/farmer_profile_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

old_block = """                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: primaryGreen));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {"""

new_block = """                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.red)));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: primaryGreen));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {"""

if old_block in content:
    content = content.replace(old_block, new_block)
    with open('lib/screens/customer/farmer_profile_screen.dart', 'w', encoding='utf-8') as f:
        f.write(content)
    print("Updated farmer profile screen with error handling")
else:
    print("Could not find block")
