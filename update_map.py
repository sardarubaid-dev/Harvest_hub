with open('lib/screens/customer/customer_home_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

import re

# Find the _popularFarmers mapping:
#           return {
#             'id': f.id,
#             'name': f.farmName.isNotEmpty ? f.farmName : 'Verified Local Farm',
#             'specialty': f.description.isNotEmpty
#                 ? f.description
#                 : 'Fresh Regional Produce',
#             'location': f.location.isNotEmpty ? f.location : 'Pakistan',
#             'rating': f.rating.toStringAsFixed(1),
#             'reviews': '(Verified)',
#             'isVerified': f.isApproved,
#             'isFollowing': false,
#             'avatarColor': const Color(0xFFA5D6A7),
#             'imageUrl': f.profileImageUrl ?? '',
#           };

pattern = r"return \{\n\s*'id': f\.id,.*?f\.profileImageUrl \?\? '',\n\s*\};"

replacement = """return {
            'id': f.id,
            'name': f.farmName.isNotEmpty ? f.farmName : 'HarvestHub Farmer',
            'specialty': f.description.isNotEmpty ? f.description : 'Fresh Local Produce',
            'location': f.location.isNotEmpty ? f.location : 'Pakistan',
            'rating': f.rating.toStringAsFixed(1),
            'reviews': '0',
            'isVerified': f.isApproved,
            'isFollowing': false,
            'avatarColor': const Color(0xFFA5D6A7),
            'imageUrl': f.profileImageUrl ?? '',
            'contactNumber': f.contactNumber,
            'createdAt': f.createdAt?.toString() ?? DateTime.now().toString(),
          };"""

content = re.sub(pattern, replacement, content, flags=re.DOTALL)

with open('lib/screens/customer/customer_home_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
print("Updated farmer map")
