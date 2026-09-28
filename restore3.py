import re
file_path = 'lib/screens/customer/customer_home_screen.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

old_qty = "'price': p.price.toStringAsFixed(0),"
new_qty = "'price': p.price.toStringAsFixed(0),\n          'quantity': p.quantity,"
content = content.replace(old_qty, new_qty)

old_dup = '''    final Set<String> validCategoryNames = availableProducts.map((p) => p['category'].toString().toLowerCase()).toSet();
    final List<CategoryModel> displayCategories = _categories.where((cat) {
      if (cat.name.toLowerCase() == 'all') return false;
      return validCategoryNames.contains(cat.name.toLowerCase());
    }).toList();'''
new_dup = '''    final Set<String> validCategoryNames = availableProducts.map((p) => p['category'].toString().toLowerCase()).toSet();
    final Set<String> _seenNames = {};
    final List<CategoryModel> displayCategories = _categories.where((cat) {
      final n = cat.name.toLowerCase();
      if (n == 'all') return false;
      if (!validCategoryNames.contains(n)) return false;
      if (_seenNames.contains(n)) return false;
      _seenNames.add(n);
      return true;
    }).toList();'''
content = content.replace(old_dup, new_dup)

content = content.replace('itemCount: _categories.length + 1,', 'itemCount: displayCategories.length + 1,')
content = content.replace('final cat = _categories[index - 1];', 'final cat = displayCategories[index - 1];')

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

  Widget _buildHarvestHubGuaranteeSection'''

content = content.replace(old_guarantee_func, promise_method)

import_str = "import '../../models/review_model.dart';"
if import_str not in content:
    content = content.replace("import '../../models/category_model.dart';", "import '../../models/category_model.dart';\n" + import_str)

old_comm_header = '''                  Text(
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
                  ),'''

new_comm_header = '''                  Row(
                    children: [
                      Text(
                        'Community Reviews',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: darkText,
                        ),
                      ),
                      const SizedBox(width: 8),
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
                  ),'''

content = content.replace(old_comm_header, new_comm_header)

with open(file_path, "w", encoding="utf-8") as f:
    f.write(content)
print("done")
