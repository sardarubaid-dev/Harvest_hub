import base64
script = b"""
import re

file_path = 'lib/screens/customer/customer_home_screen.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. quantity fix
old_qty = "'price': p.price.toStringAsFixed(0),"
new_qty = "'price': p.price.toStringAsFixed(0),\\n          'quantity': p.quantity,"
content = content.replace(old_qty, new_qty)

# 2. duplicated displayCategories fix
old_dup = '''    final String selectedCategoryName = _selectedCategoryId == '1'
        ? ''
        : _categories
            .firstWhere(
              (c) => c.id == _selectedCategoryId,
              orElse: () => CategoryModel(id: '', name: ''),
            )
            .name
            .toLowerCase();

    final List<Map<String, dynamic>> filteredProducts = _freshProducts.where((p) {
      if (_selectedCategoryId == '1') return true;
      return p['category'].toString().toLowerCase() == selectedCategoryName;
    }).toList();'''

new_dup = '''    final List<Map<String, dynamic>> availableProducts = _freshProducts.where((p) => (p['quantity'] ?? 0) > 0).toList();
    final Set<String> validCategoryNames = availableProducts.map((p) => p['category'].toString().toLowerCase()).toSet();
    final Set<String> _seenNames = {};
    final List<CategoryModel> displayCategories = _categories.where((cat) {
      final n = cat.name.toLowerCase();
      if (n == 'all') return false;
      if (!validCategoryNames.contains(n)) return false;
      if (_seenNames.contains(n)) return false;
      _seenNames.add(n);
      return true;
    }).toList();

    final String selectedCategoryName = _selectedCategoryId == '1'
        ? ''
        : displayCategories
            .firstWhere(
              (c) => c.id == _selectedCategoryId,
              orElse: () => CategoryModel(id: '', name: ''),
            )
            .name
            .toLowerCase();

    final List<Map<String, dynamic>> filteredProducts = availableProducts.where((p) {
      if (_selectedCategoryId == '1') return true;
      return p['category'].toString().toLowerCase() == selectedCategoryName;
    }).toList();'''

content = content.replace(old_dup, new_dup)

content = content.replace('itemCount: _categories.length + 1,', 'itemCount: displayCategories.length + 1,')
content = content.replace('final cat = _categories[index - 1];', 'final cat = displayCategories[index - 1];')

# 3. redesign footer
old_footer = '''          _buildHarvestHubGuaranteeSection(primaryGreen, darkText, greyText),

          const SizedBox(height: 28),

          _buildCommunityStatsSection(primaryGreen, darkText, greyText),

          const SizedBox(height: 24),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF2FDF5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xFF81C784),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.energy_savings_leaf,
                      color: Color(0xFF2E7D32),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '100% Direct-from-Farm',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: darkText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Your orders directly empower sustainable regional farmers and promote organic soil revitalization.',
                          style: TextStyle(
                            fontSize: 12,
                            color: greyText,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),'''

new_footer = '''          _buildHarvestHubPromiseSection(darkText, greyText),'''
content = content.replace(old_footer, new_footer)

old_guarantee_func = '''  Widget _buildHarvestHubGuaranteeSection'''
promise_method = '''  Widget _buildHarvestHubPromiseSection(Color darkText, Color greyText) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFD6EFD8), Color(0xFFF7FAF3)],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('The HarvestHub Promise', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: darkText, letterSpacing: -0.5)),
          const SizedBox(height: 6),
          Text('Built on trust, freshness, and local community solidarity', style: TextStyle(fontSize: 13, color: darkText.withValues(alpha: 0.8), fontWeight: FontWeight.w500)),
          const SizedBox(height: 24),
          _buildPromiseCard('100% Direct Farm Gate', 'Zero middlemen. Fair prices for growers and buyers.', 'assets/images/promise_1.png', true),
          const SizedBox(height: 12),
          _buildPromiseCard('Same-Day Harvest', 'Picked within 24 hours of fulfillment.', 'assets/images/promise_2.png', false),
          const SizedBox(height: 12),
          _buildPromiseCard('Pesticide-Free Standard', 'Natural organic cultivation and protective force-testing.', 'assets/images/promise_3.png', true),
          const SizedBox(height: 12),
          _buildPromiseCard('Community Impact', 'Empowering sustainable local Pakistani farmers.', 'assets/images/promise_4.png', false),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPromisePill('45+', 'Verified Farms'),
              _buildPromisePill('12,000+ kg', 'Harvested'),
              _buildPromisePill('100%', 'Direct Payouts'),
            ],
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFE8F5E9), Color(0xFFF1F8F1)]),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFC8E6C9), width: 1),
              boxShadow: [BoxShadow(color: const Color(0x0A000000), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Row(
              children: [
                Container(width: 60, height: 60, alignment: Alignment.center, child: Image.asset('assets/images/promise_5.png', fit: BoxFit.contain)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('100% Direct-from-Farm', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: darkText)),
                      const SizedBox(height: 4),
                      Text('Your orders directly empower sustainable regional farmers and promote organic soil revitalization.', style: TextStyle(fontSize: 12, color: darkText.withValues(alpha: 0.7), height: 1.3)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromiseCard(String title, String desc, String assetPath, bool imageLeft) {
    final textContent = Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF191D19))),
          const SizedBox(height: 4),
          Text(desc, style: const TextStyle(fontSize: 12, color: Color(0xFF40493D), height: 1.2)),
        ],
      ),
    );
    final imageContent = SizedBox(width: 75, height: 75, child: Image.asset(assetPath, fit: BoxFit.contain));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xE6FFFFFF), Color(0xE6F1F8F1)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC8E6C9), width: 1.5),
        boxShadow: [BoxShadow(color: const Color(0x0F2E7D32), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(children: imageLeft ? [imageContent, const SizedBox(width: 16), textContent] : [textContent, const SizedBox(width: 16), imageContent]),
    );
  }

  Widget _buildPromisePill(String top, String bottom) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF388E3C), Color(0xFF2E7D32)]),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: const Color(0x4D2E7D32), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Text(top, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(bottom, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _showAppReviewDialog(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You must be logged in to add a review.')));
      return;
    }
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
                    final newReview = ReviewModel(
                      id: '',
                      customerId: user.uid,
                      customerName: user.displayName ?? 'Verified Customer',
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

  Widget _buildHarvestHubGuaranteeSection'''

content = content.replace(old_guarantee_func, promise_method)

import_str = "import '../../models/review_model.dart';"
if import_str not in content:
    content = content.replace("import '../../models/category_model.dart';", "import '../../models/category_model.dart';\n" + import_str)

old_comm_header = '''              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Community Reviews',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: darkText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Real experiences from customers & families',
                    style: TextStyle(fontSize: 12, color: greyText),
                  ),
                ],
              ),'''

new_comm_header = '''              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      children: [
                        Text(
                          'Community Reviews',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: darkText,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _showAppReviewDialog(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: primaryGreen.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '+ Add Review',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: primaryGreen,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Real experiences from customers & families',
                      style: TextStyle(fontSize: 12, color: greyText),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),'''

content = content.replace(old_comm_header, new_comm_header)


# Make Deals of the Day dynamic
old_mapped = '''          'description': p.description,
        };
      }).toList();'''

new_mapped = '''          'description': p.description,
          'isDealOfTheDay': p.isDealOfTheDay,
          'originalPrice': p.originalPrice?.toStringAsFixed(0) ?? p.price.toStringAsFixed(0),
        };
      }).toList();'''
content = content.replace(old_mapped, new_mapped)

old_fresh = '''    setState(() {
      _freshProducts = mappedProducts;

      // Dynamically derive Recently Restocked from live in-stock Firestore products
      _recentlyRestocked = List.from(_freshProducts);
    });'''

new_fresh = '''    setState(() {
      _freshProducts = mappedProducts;

      // Dynamically derive Recently Restocked from live in-stock Firestore products
      _recentlyRestocked = List.from(_freshProducts);
      
      // Dynamically derive Deals of the Day
      _dealsOfTheDay = mappedProducts.where((p) => p['isDealOfTheDay'] == true).toList();
    });'''
content = content.replace(old_fresh, new_fresh)

# remove hardcoded deals list
deals_list_pattern = r'final List<Map<String, dynamic>> _dealsOfTheDay = \[\n.*?    \];'
content = re.sub(deals_list_pattern, 'List<Map<String, dynamic>> _dealsOfTheDay = [];', content, flags=re.DOTALL)

# remove fake reviews
reviews_list_pattern = r'final List<Map<String, dynamic>> _customerReviews = \[\n.*?    \];'
content = re.sub(reviews_list_pattern, 'final List<Map<String, dynamic>> _customerReviews = [];', content, flags=re.DOTALL)

# fix the reviews stream to allow empty
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
content = content.replace(old_stream, new_stream)

# handle empty reviews ui
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
content = content.replace(old_list, new_list)


# hide deals if empty
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
"""
with open('mega_restore.py', 'wb') as f:
    f.write(script)
