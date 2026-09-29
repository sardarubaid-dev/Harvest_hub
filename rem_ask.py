import re
with open('lib/screens/customer/farmer_profile_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

pattern = r"const SizedBox\(width: 8\),\n\s*Container\(\n\s*padding: const EdgeInsets\.symmetric\(\n\s*horizontal: 20,\n\s*vertical: 8,\n\s*\),\n\s*decoration: BoxDecoration\(\n\s*color: Colors\.white,\n\s*borderRadius: BorderRadius\.circular\(20\),\n\s*border: Border\.all\(\n\s*color: Colors\.grey\[300\]!,\n\s*\),\n\s*\),\n\s*child: Row\(\n\s*children: const \[\n\s*Icon\(\n\s*Icons\.chat_outlined,\n\s*size: 16,\n\s*color: darkText,\n\s*\),\n\s*SizedBox\(width: 4\),\n\s*Text\(\n\s*'Ask',\n\s*style: TextStyle\(\n\s*color: darkText,\n\s*fontWeight: FontWeight\.bold,\n\s*fontSize: 14,\n\s*\),\n\s*\),\n\s*\],\n\s*\),\n\s*\),"

content = re.sub(pattern, "", content)
with open('lib/screens/customer/farmer_profile_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
print("Removed Ask")
