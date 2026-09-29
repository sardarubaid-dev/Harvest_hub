import re

with open('lib/screens/customer/farmer_profile_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace("import 'package:provider/provider.dart';", "import 'package:provider/provider.dart';\nimport '../../providers/auth_provider.dart' as app_auth;")

content = re.sub(r"late bool isFollowing;\n\s*String _selectedCategory", "String _selectedCategory", content)
content = re.sub(r"isFollowing = widget\.farmer\['isFollowing'\] \?\? false;", "", content)
content = re.sub(r"setState\(\(\) \{\n\s*isFollowing = !isFollowing;\n\s*\}\);", "", content)

build_pattern = r"Widget build\(BuildContext context\) \{"
build_replacement = "Widget build(BuildContext context) {\n    final authProv = Provider.of<app_auth.AuthProvider>(context);\n    final isFollowing = (authProv.currentCustomer?.followedFarmers ?? []).contains(widget.farmer['id']?.toString());\n"
content = re.sub(build_pattern, build_replacement, content)

content = re.sub(r"IconButton\(\n\s*icon: const Icon\(Icons.share_outlined, color: darkText\),\n\s*onPressed: \(\) \{\},\n\s*\),", "", content)

content = re.sub(
    r"Image\.network\(\n\s*'https://images\.unsplash\.com/photo-1500937386664[^']*',\n\s*fit: BoxFit\.cover,",
    r"""Image.network(
                        (widget.farmer['imageUrl'] != null && widget.farmer['imageUrl'].toString().isNotEmpty)
                            ? widget.farmer['imageUrl']
                            : 'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?q=80&w=800&auto=format&fit=crop',
                        fit: BoxFit.cover,""",
    content
)

content = re.sub(
    r"backgroundImage: const NetworkImage\(\n\s*'https://images\.unsplash\.com/photo-1599566150163[^']*',\n\s*\),",
    r"""backgroundImage: NetworkImage(
                                (widget.farmer['imageUrl'] != null && widget.farmer['imageUrl'].toString().isNotEmpty)
                                    ? widget.farmer['imageUrl']
                                    : 'https://images.unsplash.com/photo-1599566150163-29194dcaad36?q=80&w=200&auto=format&fit=crop',
                              ),""",
    content
)

ask_match = re.search(r"GestureDetector\(\n\s*onTap: \(\) \{\},\n\s*child: Container\([\s\S]*?(?:Ask)[\s\S]*?\]\n\s*\),\n\s*\),\n\s*\),", content)
if ask_match:
    content = content.replace(ask_match.group(0), 'const SizedBox.shrink(),')

more_match = re.search(r"Container\(\n\s*padding: const EdgeInsets\.all\(8\),\n\s*decoration: BoxDecoration\(\n\s*color: Colors\.grey\[200\],\n\s*shape: BoxShape\.circle,\n\s*\),\n\s*child: const Icon\(\n\s*Icons\.more_horiz,\n\s*size: 20,\n\s*color: darkText,\n\s*\),\n\s*\)", content)
if more_match:
    content = content.replace(more_match.group(0), 'const SizedBox.shrink()')

sub_match = re.search(r"const Text\(\n\s*'Tariq Mehmood.*?2012',\n\s*style: TextStyle\(\n\s*color: greyText,\n\s*fontSize: 13,\n\s*\),\n\s*\)", content)
if sub_match:
    content = content.replace(sub_match.group(0), '''Text(
                      widget.farmer['contactNumber'] != null ? 'Contact: ' + widget.farmer['contactNumber'] : 'Verified Local Farmer',
                      style: const TextStyle(
                        color: greyText,
                        fontSize: 13,
                      ),
                    )''')

loc_match = re.search(r"Text\(\n\s*'\$\{widget\.farmer\['location'\] \?\? 'Karachi Farmers Market \(Stall 14B\)'\}.*?away',\n\s*style: const TextStyle\(fontSize: 13, color: darkText\),\n\s*\)", content)
if loc_match:
    content = content.replace(loc_match.group(0), '''Text(
                            widget.farmer['location'] ?? 'Pakistan',
                            style: const TextStyle(fontSize: 13, color: darkText),
                          )''')

on_time_match = re.search(r"Text\(\n\s*'100% On-Time Stall Fulfillment',\n\s*style: TextStyle\(fontSize: 13, color: darkText\),\n\s*\)", content)
if on_time_match:
    content = content.replace(on_time_match.group(0), '''Text(
                                'Verified HarvestHub Partner',
                                style: const TextStyle(fontSize: 13, color: darkText),
                              )''')

about_match = re.search(r"const Text\(\n\s*'Spanning 15 acres in the fertile Malir basin.*?market days\.',\n\s*style: TextStyle\(\n\s*fontSize: 14,\n\s*color: darkText,\n\s*height: 1\.5,\n\s*\),\n\s*\)", content)
if about_match:
    content = content.replace(about_match.group(0), '''Text(
                      (widget.farmer['specialty'] != null && widget.farmer['specialty'] != 'Fresh Local Produce')
                          ? widget.farmer['specialty']
                          : 'This is a verified local farm partnering with HarvestHub to bring you fresh, quality produce directly from the fields.',
                      style: const TextStyle(
                        fontSize: 14,
                        color: darkText,
                        height: 1.5,
                      ),
                    )''')

cert_match = re.search(r"Text\(\n\s*'Certified Organic Grower',\n\s*style: TextStyle\(\n\s*color: primaryGreen,\n\s*fontWeight: FontWeight\.bold,\n\s*fontSize: 12,\n\s*\),\n\s*\)", content)
if cert_match:
    content = content.replace(cert_match.group(0), '''Text(
                            widget.farmer['name'] ?? 'Fresh Produce',
                            style: const TextStyle(
                              color: Color(0xFF1B5E20),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          )''')

with open('lib/screens/customer/farmer_profile_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
print("Success")
