import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/database_service.dart';
import '../../models/review_model.dart';
import 'package:intl/intl.dart';

class FarmerReviewsTab extends StatefulWidget {
  const FarmerReviewsTab({Key? key}) : super(key: key);

  @override
  State<FarmerReviewsTab> createState() => _FarmerReviewsTabState();
}

class _FarmerReviewsTabState extends State<FarmerReviewsTab> {
  final _dbService = DatabaseService();
  final _user = FirebaseAuth.instance.currentUser;

  void _showReplyDialog(ReviewModel review) {
    final controller = TextEditingController(text: review.farmerReply?['comment'] ?? '');
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reply to Review'),
          content: TextField(
            controller: controller,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Write your public reply...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (controller.text.trim().isNotEmpty) {
                  await _dbService.addFarmerReply(review.id, _user!.uid, controller.text.trim());
                  if (mounted) Navigator.pop(context);
                }
              },
              child: const Text('Post Reply'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return const Center(child: Text("Please login first"));
    }

    const Color primaryGreen = Color(0xFF2E7D32);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Reviews'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: StreamBuilder<List<ReviewModel>>(
        stream: _dbService.streamFarmerReviews(_user!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final reviews = snapshot.data ?? [];
          if (reviews.isEmpty) {
            return const Center(child: Text('No reviews yet.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              final review = reviews[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundImage: review.userAvatar != null
                                    ? NetworkImage(review.userAvatar!)
                                    : null,
                                child: review.userAvatar == null
                                    ? const Icon(Icons.person, size: 16)
                                    : null,
                              ),
                              const SizedBox(width: 8),
                              Text(review.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Text(
                            DateFormat.yMMMd().format(review.createdAt),
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: List.generate(5, (i) {
                          return Icon(
                            i < review.rating ? Icons.star : Icons.star_border,
                            color: Colors.orange,
                            size: 16,
                          );
                        }),
                      ),
                      const SizedBox(height: 8),
                      Text(review.comment),
                      if (review.mediaUrls.isNotEmpty)
                        Container(
                          height: 60,
                          margin: const EdgeInsets.only(top: 8),
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: review.mediaUrls.length,
                            itemBuilder: (context, mIndex) {
                              return Container(
                                width: 60,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  image: DecorationImage(
                                    image: NetworkImage(review.mediaUrls[mIndex]),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 12),
                      if (review.farmerReply != null)
                        Container(
                          padding: const EdgeInsets.all(8),
                          color: Colors.grey[100],
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Your Reply:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              const SizedBox(height: 4),
                              Text(review.farmerReply!['comment']),
                            ],
                          ),
                        ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () => _showReplyDialog(review),
                          icon: Icon(review.farmerReply == null ? Icons.reply : Icons.edit, size: 16),
                          label: Text(review.farmerReply == null ? 'Reply' : 'Edit Reply'),
                          style: TextButton.styleFrom(foregroundColor: primaryGreen),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
