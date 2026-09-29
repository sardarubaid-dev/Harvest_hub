with open('lib/screens/customer/customer_home_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Modify `_toggleFollow(int index)` to not rely on local list modification, just hit DB.
# The local change doesn't hurt, but the actual state should come from the provider.
# Actually, I'll modify `_buildFarmerCard` to read from Provider dynamically.

pattern = r"bool isFollowing = data\['isFollowing'\] \?\? false;"
replacement = "final authProv = Provider.of<app_auth.AuthProvider>(context);\n    bool isFollowing = (authProv.currentCustomer?.followedFarmers ?? []).contains(data['id']?.toString());"

import re
content = re.sub(pattern, replacement, content)

with open('lib/screens/customer/customer_home_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
print("Done home screen")
