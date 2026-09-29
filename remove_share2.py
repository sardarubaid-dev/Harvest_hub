import re
with open('lib/screens/customer/farmer_profile_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

idx_share = content.find("Icons.share_outlined")
if idx_share != -1:
    start_share = content.rfind("const SizedBox(width: 8),", 0, idx_share)
    if start_share == -1: start_share = content.rfind("GestureDetector", 0, idx_share)
    if start_share == -1: start_share = content.rfind("Container", 0, idx_share)
    end_share = content.find("),", content.find("Icon", idx_share))
    end_share = content.find(",", end_share+1)
    
    # We want to replace it with SizedBox.shrink() so it doesn't break any Row/Column layouts
    content = content[:start_share] + 'const SizedBox.shrink(),' + content[end_share+1:]
    print("Removed share")

with open('lib/screens/customer/farmer_profile_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
