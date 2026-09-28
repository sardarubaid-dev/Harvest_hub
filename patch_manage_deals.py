import re
file_path = 'lib/screens/admin/admin_manage_tab.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

import_str = "import 'package:harvest_hub/screens/admin/admin_deals_screen.dart';"
if import_str not in content:
    content = content.replace("import 'package:harvest_hub/models/app_config_model.dart';", "import 'package:harvest_hub/models/app_config_model.dart';\n" + import_str)

old_section = '''            _buildOffersSection(),
            const SizedBox(height: 32),
            _buildBannersSection(),'''

new_section = '''            _buildDealsSection(),
            const SizedBox(height: 32),
            _buildOffersSection(),
            const SizedBox(height: 32),
            _buildBannersSection(),'''
content = content.replace(old_section, new_section)


deals_widget = '''  Widget _buildDealsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Deals of the Day',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              icon: const Icon(Icons.edit, size: 16),
              label: const Text('Manage Deals'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminDealsScreen()),
                );
              },
            )
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primaryContainer, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.local_fire_department, color: Colors.orange, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Promote Specific Products',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Select products to feature as "Deal of the Day" on the customer home screen.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOffersSection()'''

content = content.replace('  Widget _buildOffersSection()', deals_widget)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)
print("done")
