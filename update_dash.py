with open('lib/screens/admin/admin_dashboard_tab.dart', 'r', encoding='utf-8') as f:
    content = f.read()

import re

# Add import
import_str = "import 'admin_audit_logs_screen.dart';"
new_import = "import 'admin_audit_logs_screen.dart';\nimport 'admin_reviews_screen.dart';"
content = content.replace(import_str, new_import)

# Add button
btn_str = """_buildActionButton(Icons.security_outlined, 'Audit Logs', AppColors.surfaceVariant, onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminAuditLogsScreen()));
            }),"""
new_btn = btn_str + """\n            _buildActionButton(Icons.rate_review_outlined, 'Moderate\\nReviews', AppColors.surfaceVariant, onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminReviewsScreen()));
            }),"""
content = content.replace(btn_str, new_btn)

with open('lib/screens/admin/admin_dashboard_tab.dart', 'w', encoding='utf-8') as f:
    f.write(content)
print('Updated admin dashboard')
