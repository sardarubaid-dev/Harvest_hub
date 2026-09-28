import re

file_path = 'lib/screens/customer/customer_home_screen.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Deals map fix
old_map = """          'isOrganic': p.isOrganic,
          'description': p.description,
        };
      }).toList();"""
new_map = """          'isOrganic': p.isOrganic,
          'description': p.description,
          'isDealOfTheDay': p.isDealOfTheDay,
          'originalPrice': p.originalPrice?.toStringAsFixed(0) ?? p.price.toStringAsFixed(0),
        };
      }).toList();"""
content = content.replace(old_map, new_map)

# 2. Reviews stream fix
old_stream_full = """    // 4. Stream live Reviews from Firestore ('reviews' collection)
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
    });"""

new_stream_full = """    // 4. Stream live Reviews from Firestore ('reviews' collection)
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
    });"""
content = content.replace(old_stream_full, new_stream_full)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)
print("done!")
