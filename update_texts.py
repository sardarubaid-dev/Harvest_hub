import re
with open('lib/screens/customer/farmer_profile_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Replace Tariq Mehmood
content = re.sub(r"const Text\(\n\s*'Tariq Mehmood[^']*',\n\s*style: TextStyle\(fontSize: 14, color: darkText\),\n\s*\)", '''Text(
                    widget.farmer['contactNumber'] != null ? 'Contact: ' + widget.farmer['contactNumber'] : 'Verified Local Farmer',
                    style: const TextStyle(fontSize: 14, color: darkText),
                  )''', content)

# Replace location string completely
# Text( '${widget.farmer['location'] ?? 'Karachi Farmers Market (Stall 14B)'} • 2.4 km away', style: const TextStyle(fontSize: 13, color: darkText), )
content = re.sub(r"Text\(\n\s*'\$\{widget\.farmer\['location'\].*?away',\n\s*style: const TextStyle\(fontSize: 13, color: darkText\),\n\s*\)", '''Text(
                            widget.farmer['location'] ?? 'Pakistan',
                            style: const TextStyle(fontSize: 13, color: darkText),
                          )''', content)

# Replace Spanning 15 acres
content = re.sub(r"const Text\(\n\s*'Spanning 15 acres in the fertile Malir basin.*?',\n\s*style: TextStyle\(\n\s*fontSize: 14,\n\s*color: darkText,\n\s*height: 1\.5,\n\s*\),\n\s*\)", '''Text(
                      (widget.farmer['specialty'] != null && widget.farmer['specialty'] != 'Fresh Local Produce')
                          ? widget.farmer['specialty']
                          : 'This is a verified local farm partnering with HarvestHub to bring you fresh, quality produce directly from the fields.',
                      style: const TextStyle(
                        fontSize: 14,
                        color: darkText,
                        height: 1.5,
                      ),
                    )''', content)

# There is another fake data: "Next Harvest Drop" / "Tomorrow Morning, 8:00 AM"
content = re.sub(r"const Text\(\n\s*'NEXT HARVEST DROP',\n\s*style: TextStyle\(\n\s*color: greyText,\n\s*fontSize: 10,\n\s*fontWeight: FontWeight\.bold,\n\s*letterSpacing: 1,\n\s*\),\n\s*\),\n\s*const SizedBox\(height: 4\),\n\s*const Text\(\n\s*'Tomorrow Morning, 8:00 AM',\n\s*style: TextStyle\(\n\s*color: darkText,\n\s*fontSize: 13,\n\s*fontWeight: FontWeight\.bold,\n\s*\),\n\s*\),\n\s*const SizedBox\(height: 2\),\n\s*const Text\(\n\s*'Picked at dawn.*?14B',\n\s*style: TextStyle\(fontSize: 12, color: greyText\),\n\s*\),", '''Text(
                                  'MEMBER SINCE',
                                  style: const TextStyle(
                                    color: greyText,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.farmer['createdAt'] != null 
                                      ? widget.farmer['createdAt'].toString().substring(0, 10) 
                                      : '2022',
                                  style: const TextStyle(
                                    color: darkText,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Verified HarvestHub Partner',
                                  style: TextStyle(fontSize: 12, color: greyText),
                                ),''', content)

with open('lib/screens/customer/farmer_profile_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
print("Updated texts")
