import re

file_path = 'lib/screens/customer/customer_home_screen.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. replace hardcoded _dealsOfTheDay with dynamic one
p = r"final List<Map<String, dynamic>> _dealsOfTheDay = \[\n.*?    \];"
content = re.sub(p, "List<Map<String, dynamic>> _dealsOfTheDay = [];", content, flags=re.DOTALL)

# 2. Update mapping to include isDealOfTheDay
old_map = """          'description': p.description,
        };
      }).toList();"""
new_map = """          'description': p.description,
          'isDealOfTheDay': p.isDealOfTheDay,
          'originalPrice': p.originalPrice?.toStringAsFixed(0) ?? p.price.toStringAsFixed(0),
        };
      }).toList();"""
content = content.replace(old_map, new_map)

# 3. Update setState to map Deals
old_set = """    setState(() {
      _freshProducts = mappedProducts;

      // Dynamically derive Recently Restocked from live in-stock Firestore products
      _recentlyRestocked = List.from(_freshProducts);
    });"""
new_set = """    setState(() {
      _freshProducts = mappedProducts;
      _recentlyRestocked = List.from(_freshProducts);
      _dealsOfTheDay = mappedProducts.where((p) => p['isDealOfTheDay'] == true).toList();
    });"""
content = content.replace(old_set, new_set)

# 4. Hide deals section if empty
old_b_deals = """  Widget _buildDealsOfTheDaySection(
    Color primaryGreen,
    Color darkText,
    Color greyText,
  ) {

    return Column("""
new_b_deals = """  Widget _buildDealsOfTheDaySection(
    Color primaryGreen,
    Color darkText,
    Color greyText,
  ) {
    if (_dealsOfTheDay.isEmpty) return const SizedBox.shrink();

    return Column("""
content = content.replace(old_b_deals, new_b_deals)

# 5. Remove fake _customerReviews
p2 = r"final List<Map<String, dynamic>> _customerReviews = \[\n.*?    \];"
content = re.sub(p2, "final List<Map<String, dynamic>> _customerReviews = [];", content, flags=re.DOTALL)

# 6. Stream logic
old_sub = """    _reviewsSub = _dbService.streamAllReviews().listen((reviews) {
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
    });"""
new_sub = """    _reviewsSub = _dbService.streamAllReviews().listen((reviews) {
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
    });"""
content = content.replace(old_sub, new_sub)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)
print("done")
