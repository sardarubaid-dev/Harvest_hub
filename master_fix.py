# -*- coding: utf-8 -*-
import re

with open('lib/screens/customer/farmer_profile_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Imports and isFollowing Provider Fix
content = content.replace("import 'package:provider/provider.dart';", "import 'package:provider/provider.dart';\nimport '../../providers/auth_provider.dart' as app_auth;")
content = re.sub(r"late bool isFollowing;\n\s*String _selectedCategory", "String _selectedCategory", content)
content = re.sub(r"isFollowing = widget\.farmer\['isFollowing'\] \?\? false;", "", content)
content = re.sub(r"setState\(\(\) \{\n\s*isFollowing = !isFollowing;\n\s*\}\);", "", content)

build_pattern = r"Widget build\(BuildContext context\) \{"
build_replacement = "Widget build(BuildContext context) {\n    final authProv = Provider.of<app_auth.AuthProvider>(context);\n    final isFollowing = (authProv.currentCustomer?.followedFarmers ?? []).contains(widget.farmer['id']?.toString());\n"
content = re.sub(build_pattern, build_replacement, content)

# 2. Remove Share button in AppBar
content = re.sub(r"IconButton\(\n\s*icon: const Icon\(Icons.share_outlined, color: darkText\),\n\s*onPressed: \(\) \{\},\n\s*\),", "", content)

# 3. Banner Image
content = re.sub(
    r"Image\.network\(\n\s*'https://images\.unsplash\.com/photo-1500937386664[^']*',\n\s*fit: BoxFit\.cover,",
    r"""Image.network(
                        (widget.farmer['imageUrl'] != null && widget.farmer['imageUrl'].toString().isNotEmpty)
                            ? widget.farmer['imageUrl']
                            : 'https://placehold.co/800x400/2E7D32/FFFFFF/png?text=Farm+Profile',
                        fit: BoxFit.cover,""",
    content
)

# 4. Profile Avatar Image
content = re.sub(
    r"Image\.network\(\n\s*'https://images\.unsplash\.com/photo-1507003211169[^']*',\n\s*fit: BoxFit\.cover,",
    r"""Image.network(
                              (widget.farmer['imageUrl'] != null && widget.farmer['imageUrl'].toString().isNotEmpty)
                                  ? widget.farmer['imageUrl']
                                  : 'https://placehold.co/200x200/2E7D32/FFFFFF/png?text=F',
                              fit: BoxFit.cover,""",
    content
)

# 5. Remove Certified Organic Hub Tag
content = re.sub(
    r"Positioned\(\n\s*top: 16,\n\s*left: 16,\n\s*child: Container\(\n\s*padding: const EdgeInsets\.symmetric\(\n\s*horizontal: 12,\n\s*vertical: 6,\n\s*\),\n\s*decoration: BoxDecoration\(\n\s*color: Colors\.white,\n\s*borderRadius: BorderRadius\.circular\(20\),\n\s*\),\n\s*child: Row\(\n\s*children: const \[\n\s*Icon\(\n\s*Icons\.eco_outlined,\n\s*color: buttonGreen,\n\s*size: 14,\n\s*\),\n\s*SizedBox\(width: 4\),\n\s*Text\(\n\s*'Certified Organic Hub',\n\s*style: TextStyle\(\n\s*fontSize: 12,\n\s*fontWeight: FontWeight\.w600,\n\s*color: darkText,\n\s*\),\n\s*\),\n\s*\],\n\s*\),\n\s*\),\n\s*\),",
    "const SizedBox.shrink(),",
    content
)

# 6. Remove Ask and Share adjacent to Follow button
ask_pattern = r"const SizedBox\(width: 8\),\n\s*GestureDetector\(\n\s*onTap: \(\) \{\},\n\s*child: Container\([\s\S]*?'Ask'[\s\S]*?\]\n\s*\),\n\s*\),\n\s*\),"
content = re.sub(ask_pattern, "", content)
more_pattern = r"const SizedBox\(width: 8\),\n\s*Container\(\n\s*padding: const EdgeInsets\.all\(8\),\n\s*decoration: BoxDecoration\(\n\s*color: Colors\.grey\[200\],\n\s*shape: BoxShape\.circle,\n\s*\),\n\s*child: const Icon\(\n\s*Icons\.share_outlined,\n\s*size: 18,\n\s*color: darkText,\n\s*\),\n\s*\)"
content = re.sub(more_pattern, "", content)

# 7. Name subtitle
content = re.sub(r"const Text\(\n\s*'Tariq Mehmood[^']*',\n\s*style: TextStyle\(fontSize: 14, color: darkText\),\n\s*\)", '''Text(
                    widget.farmer['contactNumber'] != null ? 'Contact: ' + widget.farmer['contactNumber'] : 'Verified Local Farmer',
                    style: const TextStyle(fontSize: 14, color: darkText),
                  )''', content)

# 8. Location string
content = re.sub(r"Text\(\n\s*'\$\{widget\.farmer\['location'\].*?away',\n\s*style: const TextStyle\(fontSize: 13, color: darkText\),\n\s*\)", '''Text(
                            widget.farmer['location'] ?? 'Pakistan',
                            style: const TextStyle(fontSize: 13, color: darkText),
                          )''', content)

# 9. 100% On-Time
content = content.replace("100% On-Time Stall Fulfillment", "Verified HarvestHub Partner")

# 10. Next Harvest Drop SLOT completely removed
slot_pattern = r"Container\(\n\s*padding: const EdgeInsets\.all\(16\),\n\s*decoration: BoxDecoration\(\n\s*color: const Color\(0xFFE8F5E9\),\n\s*borderRadius: BorderRadius\.circular\(16\),\n\s*\),\n\s*child: Row\([\s\S]*?'NEXT HARVEST DROP'[\s\S]*?\]\n\s*\),\n\s*\),"
content = re.sub(slot_pattern, "const SizedBox.shrink(),", content)

# 11. 15 acres description
content = re.sub(r"const Text\(\n\s*'Spanning 15 acres.*?',\n\s*style: TextStyle\(\n\s*color: Color\(0xFF4B5563\),\n\s*fontSize: 14,\n\s*height: 1\.5,\n\s*\),\n\s*\)", '''Text(
                      (widget.farmer['specialty'] != null && widget.farmer['specialty'] != 'Fresh Local Produce')
                          ? widget.farmer['specialty']
                          : 'This is a verified local farm partnering with HarvestHub to bring you fresh, quality produce directly from the fields.',
                      style: const TextStyle(
                        color: Color(0xFF4B5563),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    )''', content, flags=re.DOTALL)

# 12. Remove Emojis Tags Wrap
tags_pattern = r"Wrap\(\n\s*spacing: 8,\n\s*runSpacing: 8,\n\s*children: \[[\s\S]*?'Zero Chemical Pesticides'[\s\S]*?\]\n\s*\),"
content = re.sub(tags_pattern, "const SizedBox.shrink(),", content)

# 13. Remove fake category ListView
cat_pattern = r"SizedBox\(\n\s*height: 36,\n\s*child: ListView\.builder\(\n\s*scrollDirection: Axis\.horizontal,\n\s*padding: const EdgeInsets\.symmetric\(horizontal: 16\),\n\s*itemCount: categories\.length,\n\s*itemBuilder: \(context, index\) \{[\s\S]*?\}\n\s*\),\n\s*\),\n\s*\),\n\s*\),"
content = re.sub(cat_pattern, "const SizedBox.shrink(),", content)

# Remove categories array declaration to avoid compile error since we removed the ListView
content = re.sub(r"final categories = \['All Harvest \(14\)', 'Vegetables \(8\)', 'Fruits \(4\)'\];\n", "", content)

# 14. 14 Fresh Batches
content = content.replace("'14 Fresh Batches'", "'Farm Products'")

# 15. Certified Organic Grower (subtitle of farm name)
content = content.replace("'Certified Organic Grower',", "widget.farmer['name'] ?? 'Fresh Produce',")

# 16. Remove Green Valley Farm from productMap mapping so it uses real farmer name
content = content.replace("'farmerName': p.farmerName ?? 'Green Valley Farm',", "'farmerName': p.farmerName ?? widget.farmer['name'] ?? 'Farm',")

with open('lib/screens/customer/farmer_profile_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
print("Applied master fix")
