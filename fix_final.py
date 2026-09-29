with open('lib/screens/customer/farmer_profile_screen.dart', 'r', encoding='utf-8') as f:
    lines = f.readlines()

for i in range(442, 503):
    lines[i] = ""
lines[442] = "            const SizedBox.shrink(),\n"

for i in range(543, 569):
    lines[i] = ""

if "'${widget.farmer['location']" in lines[433]:
    lines[433] = "                            '${widget.farmer['location'] ?? 'Pakistan'}',\n"

with open('lib/screens/customer/farmer_profile_screen.dart', 'w', encoding='utf-8') as f:
    f.writelines(lines)
print("Removed slot, tags and fixed location")
