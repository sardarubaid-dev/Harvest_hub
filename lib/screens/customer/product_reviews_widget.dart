import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import '../../models/product_model.dart';
import '../../models/review_model.dart';
import '../../services/database_service.dart';
import '../../services/firebase_storage_service.dart';
import '../../core/auth_interceptor.dart';
import 'package:intl/intl.dart';

const Color primaryGreen = Color(0xFF2E7D32);
const Color darkText = Color(0xFF1F2937);
const Color greyText = Color(0xFF6B7280);

class ProductReviewsWidget extends StatefulWidget {
  final ProductModel product;

  const ProductReviewsWidget({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductReviewsWidget> createState() => _ProductReviewsWidgetState();
}

class _ProductReviewsWidgetState extends State<ProductReviewsWidget> {
  final _dbService = DatabaseService();
  final _storageService = FirebaseStorageService();
  List<ReviewModel> _reviews = [];
  DocumentSnapshot? _lastDoc;
  bool _isLoading = true;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  Future<void> _fetchReviews() async {
    setState(() { _isLoading = true; });
    try {
      final res = await _dbService.getPaginatedReviews(
        productId: widget.product.id,
        limit: 5,
      );
      setState(() {
        _reviews = res['reviews'] as List<ReviewModel>;
        _lastDoc = res['lastDoc'] as DocumentSnapshot?;
        _hasMore = _reviews.length == 5;
        _isLoading = false;
      });
    } catch (e) {
      setState(() { _isLoading = false; });
    }
  }

  Future<void> _loadMoreReviews() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() { _isLoadingMore = true; });
    try {
      final res = await _dbService.getPaginatedReviews(
        productId: widget.product.id,
        limit: 5,
        startAfter: _lastDoc,
      );
      final newReviews = res['reviews'] as List<ReviewModel>;
      setState(() {
        _reviews.addAll(newReviews);
        _lastDoc = res['lastDoc'] as DocumentSnapshot?;
        _hasMore = newReviews.length == 5;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() { _isLoadingMore = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Customer Reviews',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkText),
            ),
            TextButton(
              onPressed: () => _showWriteReviewModal(context),
              child: const Text('Write Review', style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Aggregate Rating
        _buildAggregateHeader(),
        const SizedBox(height: 24),
        
        // Reviews List
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else if (_reviews.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: Text('No reviews yet. Be the first to review!', style: TextStyle(color: greyText))),
          )
        else
          ..._reviews.map((r) => _buildReviewCard(r)),
        
        if (_hasMore && !_isLoading)
          Center(
            child: TextButton(
              onPressed: _loadMoreReviews,
              child: _isLoadingMore 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Load More', style: TextStyle(color: primaryGreen)),
            ),
          ),
      ],
    );
  }

  Widget _buildAggregateHeader() {
    return Row(
      children: [
        Column(
          children: [
            Text(
              widget.product.averageRating.toStringAsFixed(1),
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: darkText),
            ),
            Row(
              children: List.generate(5, (index) {
                if (index < widget.product.averageRating.floor()) {
                  return const Icon(Icons.star, color: Colors.orange, size: 16);
                } else if (index < widget.product.averageRating.round()) {
                  return const Icon(Icons.star_half, color: Colors.orange, size: 16);
                } else {
                  return const Icon(Icons.star_border, color: Colors.orange, size: 16);
                }
              }),
            ),
            const SizedBox(height: 4),
            Text('${widget.product.totalReviews} Reviews', style: TextStyle(fontSize: 12, color: greyText)),
          ],
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            children: [5, 4, 3, 2, 1].map((stars) {
              final count = widget.product.ratingBreakdown[stars.toString()] ?? 0;
              final total = widget.product.totalReviews == 0 ? 1 : widget.product.totalReviews;
              final double percent = count / total;
              return Row(
                children: [
                  Text('$stars★', style: const TextStyle(fontSize: 12, color: darkText)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: percent,
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(width: 24, child: Text(count.toString(), style: TextStyle(fontSize: 12, color: greyText))),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewCard(ReviewModel review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey[300],
                backgroundImage: review.userAvatar != null ? NetworkImage(review.userAvatar!) : null,
                child: review.userAvatar == null ? const Icon(Icons.person, size: 16, color: Colors.white) : null,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(review.userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: darkText)),
                  if (review.isVerifiedPurchase)
                    const Text('Verified Buyer', style: TextStyle(color: primaryGreen, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
              const Spacer(),
              Text(
                DateFormat.yMMMd().format(review.createdAt),
                style: TextStyle(fontSize: 12, color: greyText),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < review.rating ? Icons.star : Icons.star_border,
                color: Colors.orange,
                size: 14,
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(review.comment, style: const TextStyle(fontSize: 14, color: darkText, height: 1.4)),
          if (review.mediaUrls.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: review.mediaUrls.length,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 80,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(review.mediaUrls[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => AuthInterceptor.executeAction(context, () async {
              final uid = FirebaseAuth.instance.currentUser?.uid;
              if (uid != null) {
                await _dbService.toggleHelpfulVote(review.id, uid);
                _fetchReviews(); // Re-fetch or update locally
              }
            }),
            child: Row(
              children: [
                Icon(Icons.thumb_up_alt_outlined, size: 14, color: greyText),
                const SizedBox(width: 4),
                Text('Helpful (${review.helpfulCount})', style: TextStyle(fontSize: 12, color: greyText)),
              ],
            ),
          ),
          if (review.farmerReply != null)
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border(left: BorderSide(color: primaryGreen, width: 3)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.storefront, size: 14, color: primaryGreen),
                      const SizedBox(width: 6),
                      Text('Farmer Response', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: darkText)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(review.farmerReply!['comment'] ?? '', style: const TextStyle(fontSize: 13, color: darkText)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showWriteReviewModal(BuildContext context) {
    AuthInterceptor.executeAction(context, () {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (_) => WriteReviewModal(product: widget.product),
      ).then((_) {
        // Refresh reviews after returning
        _fetchReviews();
      });
    });
  }
}

class WriteReviewModal extends StatefulWidget {
  final ProductModel product;

  const WriteReviewModal({Key? key, required this.product}) : super(key: key);

  @override
  State<WriteReviewModal> createState() => _WriteReviewModalState();
}

class _WriteReviewModalState extends State<WriteReviewModal> {
  int _rating = 5;
  final _commentController = TextEditingController();
  final List<File> _images = [];
  bool _isSubmitting = false;

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    setState(() {
      _images.addAll(pickedFiles.map((pf) => File(pf.path)));
    });
  }

  Future<void> _submitReview() async {
    if (_commentController.text.trim().length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Review must be at least 10 characters long.')));
      return;
    }

    setState(() { _isSubmitting = true; });
    try {
      final user = FirebaseAuth.instance.currentUser!;
      final storageService = FirebaseStorageService();
      List<String> uploadedUrls = [];

      for (var img in _images) {
        final url = await storageService.uploadReviewImage(
          productId: widget.product.id,
          userId: user.uid,
          imageFile: img,
        );
        uploadedUrls.add(url);
      }

      final review = ReviewModel(
        id: '',
        productId: widget.product.id,
        farmerId: widget.product.farmerId,
        userId: user.uid,
        userName: user.displayName ?? 'Customer',
        userAvatar: user.photoURL,
        rating: _rating,
        comment: _commentController.text.trim(),
        mediaUrls: uploadedUrls,
        isVerifiedPurchase: true, // Mock logic, ideally check orders collection
        createdAt: DateTime.now(),
      );

      await DatabaseService().addReview(review);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Review submitted successfully!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() { _isSubmitting = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Write a Review', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                icon: Icon(index < _rating ? Icons.star : Icons.star_border, color: Colors.orange, size: 32),
                onPressed: () => setState(() => _rating = index + 1),
              );
            }),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _commentController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Share your experience with this product...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(height: 16),
          if (_images.isNotEmpty)
            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _images.length,
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      Container(
                        width: 60,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(image: FileImage(_images[index]), fit: BoxFit.cover),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 8,
                        child: GestureDetector(
                          onTap: () => setState(() => _images.removeAt(index)),
                          child: const CircleAvatar(radius: 10, backgroundColor: Colors.red, child: Icon(Icons.close, size: 12, color: Colors.white)),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          TextButton.icon(
            onPressed: _pickImages,
            icon: const Icon(Icons.add_a_photo),
            label: const Text('Add Photos'),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitReview,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32), foregroundColor: Colors.white),
              child: _isSubmitting ? const CircularProgressIndicator(color: Colors.white) : const Text('Submit Review'),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
