import re

with open('lib/screens/role_selection_screen.dart', 'r', encoding='utf-8') as f:
    c = f.read()

c = c.replace(
    "_buildFeaturePill(Icons.local_shipping_outlined, 'Direct pickup', primaryGreen),",
    "_buildFeaturePill(Icons.local_shipping_outlined, 'Direct pickup', primaryGreen, null, const Color(0xFFE8F5E9)),"
)
c = c.replace(
    "_buildFeaturePill(Icons.wb_sunny_outlined, 'Seasonal freshness', primaryGreen),",
    "_buildFeaturePill(Icons.wb_sunny_outlined, 'Seasonal freshness', primaryGreen, null, const Color(0xFFE8F5E9)),"
)
c = c.replace(
    "_buildFeaturePill(Icons.verified_user_outlined, 'Verified growers', primaryGreen),",
    "_buildFeaturePill(Icons.verified_user_outlined, 'Verified growers', primaryGreen, null, const Color(0xFFE8F5E9)),"
)

old_pill_def = r"Widget _buildFeaturePill\(IconData icon, String text, Color textColor, \[Color\? iconColor\]\) \{"
new_pill_def = r"Widget _buildFeaturePill(IconData icon, String text, Color textColor, [Color? iconColor, Color? bgColor]) {"
c = re.sub(old_pill_def, new_pill_def, c)

c = c.replace(
    "color: const Color(0xFFF3F4F6),",
    "color: bgColor ?? const Color(0xFFF3F4F6),"
)

with open('lib/screens/role_selection_screen.dart', 'w', encoding='utf-8') as f:
    f.write(c)
