import re
with open('lib/screens/customer/farmer_profile_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Replace Tariq Mehmood
sub_match = re.search(r"const Text\(\n\s*'Tariq Mehmood[^']*2012',\n\s*style: TextStyle\(\n\s*color: greyText,\n\s*fontSize: 13,\n\s*\),\n\s*\)", content)
if sub_match:
    content = content.replace(sub_match.group(0), '''Text(
                      widget.farmer['contactNumber'] != null ? 'Contact: ' + widget.farmer['contactNumber'] : 'Verified Local Farmer',
                      style: const TextStyle(
                        color: greyText,
                        fontSize: 13,
                      ),
                    )''')

# Replace Karachi Farmers Market
loc_match = re.search(r"Text\(\n\s*'\$\{widget\.farmer\['location'\] \?\? 'Karachi Farmers Market \(Stall 14B\)'\}[^']*away',\n\s*style: const TextStyle\(fontSize: 13, color: darkText\),\n\s*\)", content)
if loc_match:
    content = content.replace(loc_match.group(0), '''Text(
                            widget.farmer['location'] ?? 'Pakistan',
                            style: const TextStyle(fontSize: 13, color: darkText),
                          )''')

# Replace Spanning 15 acres
about_match = re.search(r"const Text\(\n\s*'Spanning 15 acres in the fertile Malir basin[^']*market days\.',\n\s*style: TextStyle\(\n\s*fontSize: 14,\n\s*color: darkText,\n\s*height: 1\.5,\n\s*\),\n\s*\)", content)
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

with open('lib/screens/customer/farmer_profile_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
print("Replaced fake texts")
