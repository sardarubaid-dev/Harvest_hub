with open('lib/screens/customer/customer_home_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Change "Fresh Near You" to "Top Selling", and subtitle "Today" to "Trending"
content = content.replace("_buildSectionHeader('Fresh Near You', 'Today')", "_buildSectionHeader('Top Selling', 'Trending')")

# Change the height of the ListView container that directly follows it.
# The code looks like:
#           _buildSectionHeader('Top Selling', 'Trending'),
#           const SizedBox(height: 16),
#           SizedBox(
#             height: 300,
#             child: ListView.builder(
import re
pattern = r"_buildSectionHeader\('Top Selling', 'Trending'\),\n\s*const SizedBox\(height: 16\),\n\s*SizedBox\(\n\s*height: 300,"
replacement = "_buildSectionHeader('Top Selling', 'Trending'),\n            const SizedBox(height: 16),\n            SizedBox(\n              height: 260,"
content = re.sub(pattern, replacement, content)

with open('lib/screens/customer/customer_home_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
print("Done")
