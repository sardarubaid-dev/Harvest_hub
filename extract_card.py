import re

with open('lib/screens/customer/customer_home_screen.dart', 'r', encoding='utf-8') as f:
    home_content = f.read()

start_idx = home_content.find('Widget _buildProductCard({')
end_idx = home_content.find('Widget _buildFarmerCard({')
card_code = home_content[start_idx:end_idx].strip()

# Convert _buildProductCard to a standalone StatefulWidget (to handle context and providers) or StatelessWidget.
# Since it needs context for Navigator and Providers, a StatelessWidget is perfect.

# Replace function signature with build method
card_class = """import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/product_model.dart';
import '../../services/database_service.dart';
import '../../providers/cart_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../core/auth_interceptor.dart';
import '../customer/product_detail_screen.dart';

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onAddTap;

  const ProductCard({
    Key? key,
    required this.data,
    this.onFavoriteTap,
    this.onAddTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _dbService = DatabaseService();
"""
# The body of the function is just the `return GestureDetector...`
# Let's extract the body.
body_start = card_code.find('return GestureDetector(')
body = card_code[body_start:]

card_class += "    " + body + "\n}\n"

with open('lib/screens/shared/product_card_widget.dart', 'w', encoding='utf-8') as f:
    f.write(card_class)
print("Created product_card_widget.dart")
