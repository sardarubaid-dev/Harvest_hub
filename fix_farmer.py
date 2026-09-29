import re

with open('lib/screens/customer/farmer_profile_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Replace local state usage of isFollowing with dynamic calculation
pattern = r"late bool isFollowing;\n\s*String _selectedCategory"
replacement = "String _selectedCategory"
content = re.sub(pattern, replacement, content)

pattern = r"isFollowing = widget\.farmer\['isFollowing'\] \?\? false;"
replacement = ""
content = re.sub(pattern, replacement, content)

# In _toggleFollow, remove local setState
pattern = r"setState\(\(\) \{\n\s*isFollowing = !isFollowing;\n\s*\}\);"
replacement = ""
content = re.sub(pattern, replacement, content)

# Instead of modifying the UI occurrences one by one (which is error prone),
# I'll just declare `isFollowing` at the top of the build method!
build_pattern = r"Widget build\(BuildContext context\) \{"
build_replacement = "Widget build(BuildContext context) {\n    final authProv = Provider.of<app_auth.AuthProvider>(context);\n    final isFollowing = (authProv.currentCustomer?.followedFarmers ?? []).contains(widget.farmer['id']?.toString());\n"
content = re.sub(build_pattern, build_replacement, content)

with open('lib/screens/customer/farmer_profile_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
print("Done farmer_profile_screen")
