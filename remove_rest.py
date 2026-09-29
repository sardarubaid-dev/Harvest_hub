import re
with open('lib/screens/customer/farmer_profile_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

idx_ask = content.find("'Ask'")
if idx_ask != -1:
    start_ask = content.rfind("const SizedBox(width: 8),", 0, idx_ask)
    if start_ask == -1: start_ask = content.rfind("GestureDetector", 0, idx_ask)
    # The container ends with ], ), ), )
    end_ask = content.find("),", content.find("]", idx_ask))
    end_ask = content.find("),", end_ask+1)
    end_ask = content.find(",", end_ask+1)
    content = content[:start_ask] + content[end_ask+1:]
    print("Removed ask")

idx_more = content.find("Icons.more_horiz")
if idx_more != -1:
    start_more = content.rfind("const SizedBox(width: 8),", 0, idx_more)
    if start_more == -1: start_more = content.rfind("Container", 0, idx_more)
    end_more = content.find("),", content.find("Icon", idx_more))
    end_more = content.find(",", end_more+1)
    content = content[:start_more] + content[end_more+1:]
    print("Removed more")

# Emojis tags section
# Zero Chemical Pesticides
idx_emojis = content.find("Zero Chemical Pesticides")
if idx_emojis != -1:
    start_wrap = content.rfind("Wrap(", 0, idx_emojis)
    if start_wrap != -1:
        end_wrap = content.find("),", content.find("]", idx_emojis))
        content = content[:start_wrap] + 'const SizedBox.shrink(),' + content[end_wrap+2:]
        print("Removed emojis wrap")

with open('lib/screens/customer/farmer_profile_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
