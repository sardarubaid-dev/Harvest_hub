import re
file_path = 'lib/screens/customer/customer_home_screen.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Remove hardcoded reviews
old_init = '''  final List<Map<String, dynamic>> _customerReviews = [
    {
      'name': 'Ayesha Khan',
      'location': 'DHA Phase 6, Karachi',
      'rating': 5,
      'date': 'Yesterday',
      'avatar':
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=200&auto=format&fit=crop',
      'review':
          'The beefsteak tomatoes and spinach were harvested the exact same morning! Unmatched freshness compared to standard supermarket produce.',
      'product': 'Fresh Tomatoes',
    },
  ];'''
new_init = '''  final List<Map<String, dynamic>> _customerReviews = [];'''
if old_init in content:
    content = content.replace(old_init, new_init)

# 2. Fix the stream listener to allow empty
old_stream = '''    // 4. Stream live Reviews from Firestore ('reviews' collection)
    _reviewsSub = _dbService.streamAllReviews().listen((reviews) {
      if (!mounted || reviews.isEmpty) return;
      setState(() {
        _customerReviews
          ..clear()
          ..addAll(
            reviews.map((r) {
              return {
                'name': r.customerName.isNotEmpty ? r.customerName : 'Verified Buyer',
                'location': 'Verified Order',
                'rating': r.rating.round().clamp(1, 5),
                'date': 'Recent',
                'avatar':
                    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=200&auto=format&fit=crop',
                'review': r.comment,
                'product': 'HarvestHub App',
              };
            }).toList(),
          );
      });
    });'''
new_stream = '''    // 4. Stream live Reviews from Firestore ('reviews' collection)
    _reviewsSub = _dbService.streamAllReviews().listen((reviews) {
      if (!mounted) return;
      setState(() {
        _customerReviews.clear();
        _customerReviews.addAll(
          reviews.map((r) {
            return {
              'name': r.customerName.isNotEmpty ? r.customerName : 'Verified Buyer',
              'location': 'Verified Order',
              'rating': r.rating.round().clamp(1, 5),
              'date': 'Recent',
              'avatar': r.customerAvatar != null && r.customerAvatar!.isNotEmpty ? r.customerAvatar : 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=200&auto=format&fit=crop',
              'review': r.comment,
              'product': 'HarvestHub App',
            };
          }).toList(),
        );
      });
    });'''
if old_stream in content:
    content = content.replace(old_stream, new_stream)

# 3. Handle empty state in the list builder
old_list = '''        const SizedBox(height: 14),
        SizedBox(
          height: 175,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _customerReviews.length,
            itemBuilder: (context, index) {'''
new_list = '''        const SizedBox(height: 14),
        if (_customerReviews.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: const Color(0xFFF9FBF9), borderRadius: BorderRadius.circular(12)),
              child: const Text('No reviews yet. Be the first to share your experience!', style: TextStyle(color: Color(0xFF6B7280)), textAlign: TextAlign.center),
            ),
          )
        else
          SizedBox(
            height: 175,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _customerReviews.length,
              itemBuilder: (context, index) {'''
if old_list in content:
    content = content.replace(old_list, new_list)

# 4. Require Login in _showAppReviewDialog
old_dialog = '''  void _showAppReviewDialog(BuildContext context) {
    int selectedRating = 5;
    final commentController = TextEditingController();
    showDialog('''
new_dialog = '''  void _showAppReviewDialog(BuildContext context) {
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
