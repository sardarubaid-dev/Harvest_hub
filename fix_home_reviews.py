import re

file_path = 'lib/screens/customer/customer_home_screen.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Remove the incorrectly placed method at the end
end_idx = content.rfind('  void _showAppReviewDialog(BuildContext context) {')
if end_idx != -1:
    content = content[:end_idx]

# Inject it at the end of _CustomerHomeScreenState, which ends right before class _CustomerHomeHeaderDelegate
target = "class _CustomerHomeHeaderDelegate extends SliverPersistentHeaderDelegate {"
dialog_method = '''
  void _showAppReviewDialog(BuildContext context) {
    int selectedRating = 5;
    final commentController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateSB) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Write an App Review'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(index < selectedRating ? Icons.star : Icons.star_border, color: Colors.orange, size: 32),
                        onPressed: () => setStateSB(() => selectedRating = index + 1),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: commentController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Share your experience with HarvestHub...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
                ElevatedButton(
                  onPressed: () async {
                    if (commentController.text.trim().isEmpty) return;
                    final user = FirebaseAuth.instance.currentUser;
                    final newReview = ReviewModel(
                      id: '',
                      customerId: user?.uid ?? 'guest',
                      customerName: user?.displayName ?? 'Verified Customer',
                      targetType: 'app',
                      targetId: 'harvesthub_app',
                      rating: selectedRating.toDouble(),
                      comment: commentController.text.trim(),
                      createdAt: DateTime.now(),
                    );
                    await DatabaseService().addReview(newReview);
                    if (mounted) Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  child: const Text('Submit'),
                ),
              ],
            );
          }
        );
      },
    );
  }
}
'''
content = content.replace(target, dialog_method + target)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)
