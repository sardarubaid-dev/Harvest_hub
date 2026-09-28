import re
file_path = 'lib/screens/customer/customer_home_screen.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

old_deals = '''  Widget _buildDealsOfTheDaySection(
    Color primaryGreen,
    Color darkText,
    Color greyText,
  ) {

    return Column('''

new_deals = '''  Widget _buildDealsOfTheDaySection(
    Color primaryGreen,
    Color darkText,
    Color greyText,
  ) {
    if (_dealsOfTheDay.isEmpty) return const SizedBox.shrink();

    return Column('''

content = content.replace(old_deals, new_deals)
with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)
print('done')
