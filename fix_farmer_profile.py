import re
with open('lib/screens/customer/farmer_profile_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Fix import
content = content.replace("import 'package:provider/provider.dart';", "import 'package:provider/provider.dart';\nimport '../../providers/auth_provider.dart' as app_auth;")

# Remove local isFollowing state
content = re.sub(r"late bool isFollowing;\n\s*String _selectedCategory", "String _selectedCategory", content)
content = re.sub(r"isFollowing = widget\.farmer\['isFollowing'\] \?\? false;", "", content)
content = re.sub(r"setState\(\(\) \{\n\s*isFollowing = !isFollowing;\n\s*\}\);", "", content)

# Inject dynamic isFollowing in build
build_pattern = r"Widget build\(BuildContext context\) \{"
build_replacement = "Widget build(BuildContext context) {\n    final authProv = Provider.of<app_auth.AuthProvider>(context);\n    final isFollowing = (authProv.currentCustomer?.followedFarmers ?? []).contains(widget.farmer['id']?.toString());\n"
content = re.sub(build_pattern, build_replacement, content)

# Remove Share Button
content = re.sub(r"IconButton\(\n\s*icon: const Icon\(Icons.share_outlined, color: darkText\),\n\s*onPressed: \(\) \{\},\n\s*\),", "", content)

# Banner image replacement
content = re.sub(
    r"Image\.network\(\n\s*'https://images\.unsplash\.com/photo-1500937386664-56d1dfef3854[^']*',\n\s*fit: BoxFit\.cover,",
    r"""Image.network(
                        (widget.farmer['imageUrl'] != null && widget.farmer['imageUrl'].toString().isNotEmpty)
                            ? widget.farmer['imageUrl']
                            : 'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?q=80&w=800&auto=format&fit=crop',
                        fit: BoxFit.cover,""",
    content
)

# Avatar image replacement
content = re.sub(
    r"backgroundImage: const NetworkImage\(\n\s*'https://images\.unsplash\.com/photo-1599566150163-29194dcaad36[^']*',\n\s*\),",
    r"""backgroundImage: NetworkImage(
                                (widget.farmer['imageUrl'] != null && widget.farmer['imageUrl'].toString().isNotEmpty)
                                    ? widget.farmer['imageUrl']
                                    : 'https://images.unsplash.com/photo-1599566150163-29194dcaad36?q=80&w=200&auto=format&fit=crop',
                              ),""",
    content
)

# Remove the Ask and Share containers next to Follow
# The Follow button is in a Row. After the Follow button, there are SizeBox and other things.
# I will just replace the "Ask" text with an empty string, or better, replace the whole container with SizedBox.shrink().
# Actually, the Ask button has a child: Text('Ask', ...). Let's use regex to find the Ask GestureDetector.
pattern_ask = r"GestureDetector\(\n\s*onTap: \(\) \{\},\n\s*child: Container\(\n\s*padding: const EdgeInsets\.symmetric\(\n\s*horizontal: 20,\n\s*vertical: 8,\n\s*\).*?'Ask'.*?\]\n\s*\),\n\s*\),\n\s*\),"
content = re.sub(pattern_ask, "const SizedBox.shrink(),", content, flags=re.DOTALL)

# Also remove the grey circle button next to it (which is probably share or options)
pattern_more = r"Container\(\n\s*padding: const EdgeInsets\.all\(8\),\n\s*decoration: BoxDecoration\(\n\s*color: Colors\.grey\[200\],\n\s*shape: BoxShape\.circle,\n\s*\),\n\s*child: const Icon\(\n\s*Icons\.more_horiz,\n\s*size: 20,\n\s*color: darkText,\n\s*\),\n\s*\)"
content = re.sub(pattern_more, "const SizedBox.shrink()", content, flags=re.DOTALL)

# Dynamic texts replacement
# 1. Name subtitle (Tariq Mehmood • Farmer & Orchardist since 2012)
content = re.sub(
    r"const Text\(\n\s*'Tariq Mehmood.*?2012',\n\s*style: TextStyle\(\n\s*color: greyText,\n\s*fontSize: 13,\n\s*\),\n\s*\)",
    r"""Text(
                      widget.farmer['contactNumber'] != null ? 'Contact: ${widget.farmer['contactNumber']}' : 'Verified Local Farmer',
                      style: const TextStyle(
                        color: greyText,
                        fontSize: 13,
                      ),
                    )""",
    content
)

# 2. Location details (Karachi Farmers Market (Stall 14B) • 2.4 km away)
content = re.sub(
    r"Text\(\n\s*'\$\{widget\.farmer\['location'\] \?\? 'Karachi Farmers Market \(Stall 14B\)'\} • 2\.4 km away',\n\s*style: const TextStyle\(fontSize: 13, color: darkText\),\n\s*\)",
    r"""Text(
                            '${widget.farmer['location'] ?? 'Pakistan'}',
                            style: const TextStyle(fontSize: 13, color: darkText),
                          )""",
    content
)

# 3. 100% On-Time Stall Fulfillment
content = re.sub(
    r"Text\(\n\s*'100% On-Time Stall Fulfillment',\n\s*style: TextStyle\(fontSize: 13, color: darkText\),\n\s*\)",
    r"""Text(
                                'Verified HarvestHub Partner',
                                style: TextStyle(fontSize: 13, color: darkText),
                              )""",
    content
)

# 4. Long About Us string
content = re.sub(
    r"const Text\(\n\s*'Spanning 15 acres in the fertile Malir basin.*?market days\.',\n\s*style: TextStyle\(\n\s*fontSize: 14,\n\s*color: darkText,\n\s*height: 1\.5,\n\s*\),\n\s*\)",
    r"""Text(
                      (widget.farmer['description'] != null && widget.farmer['description'].toString().isNotEmpty)
                          ? widget.farmer['description']
                          : 'This is a verified local farm partnering with HarvestHub to bring you fresh, quality produce directly from the fields.',
                      style: const TextStyle(
                        fontSize: 14,
                        color: darkText,
                        height: 1.5,
                      ),
                    )""",
    content
)

# 5. "Certified Organic Grower" text
content = re.sub(
    r"Text\(\n\s*'Certified Organic Grower',\n\s*style: TextStyle\(\n\s*color: primaryGreen,\n\s*fontWeight: FontWeight\.bold,\n\s*fontSize: 12,\n\s*\),\n\s*\)",
    r"""Text(
                            widget.farmer['specialty'] ?? 'Fresh Produce',
                            style: TextStyle(
                              color: primaryGreen,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          )""",
    content
)

with open('lib/screens/customer/farmer_profile_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
print("Updated all")
