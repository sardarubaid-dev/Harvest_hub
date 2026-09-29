import re
with open('lib/screens/customer/farmer_profile_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Remove categories definition
content = re.sub(r"final categories = \['All Harvest \(14\)', 'Vegetables \(8\)', 'Fruits \(4\)'\];\n\s*", "", content)

# Remove the ListView for categories
# It's inside a SizedBox(height: 36)
cat_list_match = re.search(r"SizedBox\(\n\s*height: 36,\n\s*child: ListView\.builder\(\n\s*scrollDirection: Axis\.horizontal,\n\s*padding: const EdgeInsets\.symmetric\(horizontal: 16\),\n\s*itemCount: categories\.length,\n\s*itemBuilder: \(context, index\) \{[\s\S]*?\}\n\s*\),\n\s*\),\n\s*\),\n\s*\),", content)
if cat_list_match:
    content = content.replace(cat_list_match.group(0), "")
else:
    # Just in case the regex is too strict
    print("Could not find cat list")

# Replace green valley farm with real name inside the product map
content = content.replace("'farmerName': p.farmerName ?? 'Green Valley Farm',", "'farmerName': p.farmerName ?? widget.farmer['name'],")

with open('lib/screens/customer/farmer_profile_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
print("Done")
