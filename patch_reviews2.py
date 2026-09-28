import re
file_path = 'lib/screens/customer/product_detail_screen.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

import_str = "import '../../models/review_model.dart';"
if import_str not in content:
    content = content.replace("import 'package:provider/provider.dart';", "import 'package:provider/provider.dart';\n" + import_str)

old_section = '''                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),'''

new_section = '''                          const SizedBox(height: 16),
                          _buildReviewsSection(),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),'''

content = content.replace(old_section, new_section)

reviews_widget = '''
  Widget _buildReviewsSection() {
    final productId = widget.product?['id'] ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Customer Reviews',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
            ),
            TextButton(
              onPressed: () => _showReviewDialog(productId),
              child: const Text('Write a Review', style: TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        StreamBuilder<List<ReviewModel>>(
          stream: DatabaseService().streamProductReviews(productId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final reviews = snapshot.data ?? [];
            if (reviews.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: const Color(0xFFF9FBF9), borderRadius: BorderRadius.circular(12)),
                child: const Text('No reviews yet. Be the first to review this product!', style: TextStyle(color: Color(0xFF6B7280)), textAlign: TextAlign.center),
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                final rev = reviews[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E7EB))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(radius: 16, backgroundColor: const Color(0xFFA5D6A7), child: Text(rev.customerName.isNotEmpty ? rev.customerName[0].toUpperCase() : 'C', style: const TextStyle(fontSize: 12, color: Colors.white))),
                              const SizedBox(width: 8),
                              Text(rev.customerName.isNotEmpty ? rev.customerName : 'Verified Customer', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            ],
                          ),
                          Row(
                            children: List.generate(5, (starIdx) => Icon(starIdx < rev.rating ? Icons.star : Icons.star_border, color: Colors.orange, size: 14)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(rev.comment, style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563))),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  void _showReviewDialog(String productId) {
    int selectedRating = 5;
    final commentController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateSB) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Write a Review'),
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
                      hintText: 'Share your experience with this product...',
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
                      targetType: 'product',
                      targetId: productId,
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
'''

content = content.replace('  Widget _buildProductProperty(String label, String value) {', reviews_widget + '\n  Widget _buildProductProperty(String label, String value) {')

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)
print("done")
