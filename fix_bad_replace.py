import re

with open('lib/screens/role_selection_screen.dart', 'r', encoding='utf-8') as f:
    c = f.read()

c = c.replace('color: bgColor ?? const Color(0xFFF3F4F6),', 'color: const Color(0xFFF3F4F6),')

# Only in _buildFeaturePill
c = c.replace('''  Widget _buildFeaturePill(IconData icon, String text, Color textColor, [Color? iconColor, Color? bgColor]) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),''', '''  Widget _buildFeaturePill(IconData icon, String text, Color textColor, [Color? iconColor, Color? bgColor]) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor ?? const Color(0xFFF3F4F6),''')


with open('lib/screens/role_selection_screen.dart', 'w', encoding='utf-8') as f:
    f.write(c)
