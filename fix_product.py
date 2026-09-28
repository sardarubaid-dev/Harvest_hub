import re
file_path = 'lib/screens/customer/product_detail_screen.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

old_dialog = '''  void _showReviewDialog(String productId) {
    int selectedRating = 5;
    final commentController = TextEditingController();
    showDialog('''
new_dialog = '''  void _showReviewDialog(String productId) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You must be logged in to add a review.')));
      return;
    }
    int selectedRating = 5;
    final commentController = TextEditingController();
    showDialog('''
if old_dialog in content:
    content = content.replace(old_dialog, new_dialog)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)
print('done')
