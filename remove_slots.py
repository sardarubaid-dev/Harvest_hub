with open('lib/screens/customer/farmer_profile_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Fix Avatar Image
# Original: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=200&auto=format&fit=crop'
content = content.replace("'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=200&auto=format&fit=crop'", "(widget.farmer['imageUrl'] != null && widget.farmer['imageUrl'].toString().isNotEmpty) ? widget.farmer['imageUrl'] : 'https://placehold.co/200x200/2E7D32/FFFFFF/png?text=' + (widget.farmer['name'] != null ? widget.farmer['name'][0].toUpperCase() : 'F')")

# Fix Banner Image
# Original fallback: 'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?q=80&w=800&auto=format&fit=crop'
content = content.replace("'https://images.unsplash.com/photo-1500937386664-56d1dfef3854?q=80&w=800&auto=format&fit=crop'", "'https://placehold.co/800x400/1F2937/FFFFFF/png?text=Farm+Profile'")

# 2. Remove "Certified Organic Hub" tag
idx1 = content.find("Positioned(\n                    top: 16,\n                    left: 16,")
if idx1 != -1:
    idx2 = content.find("),", content.find("Text(\n                            'Certified Organic Hub'", idx1))
    idx2 = content.find("),", idx2+1)
    idx2 = content.find("),", idx2+1)
    idx2 = content.find(",", idx2+1)
    content = content[:idx1] + content[idx2+1:]

# 3. Ask button again just in case (the previous script failed for it)
import re
ask_pattern = r"const SizedBox\(width: 8\),\n\s*GestureDetector\(\n\s*onTap: \(\) \{\},\n\s*child: Container\([\s\S]*?'Ask'[\s\S]*?\]\n\s*\),\n\s*\),\n\s*\),"
content = re.sub(ask_pattern, "", content)

# 4. Remove Next Harvest Drop completely (The slot)
harvest_drop_pattern = r"Container\(\n\s*padding: const EdgeInsets\.all\(16\),\n\s*decoration: BoxDecoration\(\n\s*color: const Color\(0xFFE8F5E9\),\n\s*borderRadius: BorderRadius\.circular\(16\),\n\s*\),\n\s*child: Row\([\s\S]*?\]\n\s*\),\n\s*\),"
content = re.sub(harvest_drop_pattern, "const SizedBox.shrink(),", content)

# 5. Remove the Emojis / Tags section (Zero Chemical Pesticides, etc)
tags_pattern = r"Wrap\(\n\s*spacing: 8,\n\s*runSpacing: 8,\n\s*children: \[[\s\S]*?\]\n\s*\),"
content = re.sub(tags_pattern, "const SizedBox.shrink(),", content)

with open('lib/screens/customer/farmer_profile_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
print("Applied fixes")
