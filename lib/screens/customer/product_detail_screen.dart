import 'package:flutter/material.dart';
import '../../core/dummy_data.dart';
import '../../core/auth_interceptor.dart';
import 'farmer_profile_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic>? product;

  const ProductDetailScreen({Key? key, this.product}) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  late int _pricePerUnit;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    // Default to the exact data from the design if not provided
    final p = widget.product;
    _pricePerUnit = p != null ? int.tryParse(p['price'].toString()) ?? 280 : 280;
    _isFavorite = p != null ? (p['isFavorite'] ?? false) : false;
  }

  void _increment() {
    setState(() => _quantity++);
  }

  void _decrement() {
    if (_quantity > 1) setState(() => _quantity--);
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF2E7D32);
    const Color darkText = Color(0xFF1F2937);
    const Color greyText = Color(0xFF6B7280);
    const Color background = Color(0xFFF9FBF9);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Container(
              color: background,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: darkText),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: primaryGreen,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.eco, color: Colors.white, size: 16),
                      ),
                      const SizedBox(width: 6),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('HarvestHub', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: darkText, height: 1.0)),
                          const Text('LOCAL FARM MARKETPLACE', style: TextStyle(fontSize: 6, fontWeight: FontWeight.bold, color: greyText, letterSpacing: 0.5)),
                        ],
                      ),
                    ],
                  ),
                  const Text('Product...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkText)),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(color: primaryGreen, shape: BoxShape.circle),
                    child: const Icon(Icons.person, color: Colors.white, size: 18),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero Image Area
                    Stack(
                      children: [
                        Container(
                          height: 300,
                          width: double.infinity,
                          color: widget.product?['imageColor'] ?? Colors.red[300],
                          // If we had a real image URL, we'd use Image.network
                          // For now, we simulate the tomatoes image with a colored block or placeholder
                          child: widget.product == null 
                              ? Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    // Simulated image background
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [Colors.green[200]!, Colors.red[300]!],
                                        )
                                      ),
                                    ),
                                    const Center(child: Icon(Icons.image, size: 100, color: Colors.white54)),
                                  ],
                                )
                              : const Center(child: Icon(Icons.image, size: 100, color: Colors.white54)),
                        ),
                        Positioned(
                          top: 16,
                          right: 16,
                          child: GestureDetector(
                            onTap: () => AuthInterceptor.executeAction(context, () => setState(() => _isFavorite = !_isFavorite)),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                              child: Icon(
                                _isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: _isFavorite ? Colors.red : darkText,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 16,
                          left: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(16)),
                            child: Row(
                              children: const [
                                Icon(Icons.photo_library_outlined, color: Colors.white, size: 14),
                                SizedBox(width: 6),
                                Text('1 / 4', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.8), borderRadius: BorderRadius.circular(12)),
                            child: Row(
                              children: [
                                Container(width: 6, height: 6, decoration: const BoxDecoration(color: primaryGreen, shape: BoxShape.circle)),
                                const SizedBox(width: 4),
                                Container(width: 6, height: 6, decoration: BoxDecoration(color: Colors.grey[400], shape: BoxShape.circle)),
                                const SizedBox(width: 4),
                                Container(width: 6, height: 6, decoration: BoxDecoration(color: Colors.grey[400], shape: BoxShape.circle)),
                                const SizedBox(width: 4),
                                Container(width: 6, height: 6, decoration: BoxDecoration(color: Colors.grey[400], shape: BoxShape.circle)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Badges
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(16)),
                                child: Row(
                                  children: const [
                                    CircleAvatar(radius: 3, backgroundColor: primaryGreen),
                                    SizedBox(width: 6),
                                    Text('In Stock • 12 kg available', style: TextStyle(color: primaryGreen, fontSize: 11, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                              Row(
                                children: const [
                                  Icon(Icons.verified_outlined, color: primaryGreen, size: 14),
                                  SizedBox(width: 4),
                                  Text('Verified Harvest', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: darkText)),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          
                          // Title & Price
                          Text(widget.product?['title'] ?? 'Fresh Tomatoes', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: darkText)),
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('Rs. $_pricePerUnit', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: primaryGreen)),
                              Text(widget.product?['unit'] ?? ' / kg', style: const TextStyle(fontSize: 14, color: greyText, height: 1.5)),
                            ],
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // Ratings
                          Row(
                            children: [
                              const Icon(Icons.star_border, color: Colors.orange, size: 16),
                              const Icon(Icons.star_border, color: Colors.orange, size: 16),
                              const Icon(Icons.star_border, color: Colors.orange, size: 16),
                              const Icon(Icons.star_border, color: Colors.orange, size: 16),
                              const Icon(Icons.star_half, color: Colors.orange, size: 16),
                              const SizedBox(width: 8),
                              const Text('4.8', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: darkText)),
                              const SizedBox(width: 4),
                              const Text('(84 reviews)', style: TextStyle(fontSize: 13, color: greyText)),
                              const SizedBox(width: 8),
                              Container(width: 4, height: 4, decoration: const BoxDecoration(color: greyText, shape: BoxShape.circle)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(4)),
                            child: const Text('98% Verified Buyers', style: TextStyle(color: primaryGreen, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),

                          const SizedBox(height: 16),

                          // Harvest Timeline
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(12)),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(color: Color(0xFFE5E7EB), shape: BoxShape.circle),
                                  child: const Icon(Icons.access_time, size: 16, color: primaryGreen),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text('Harvest Timeline', style: TextStyle(fontSize: 10, color: greyText)),
                                    Text('Harvested yesterday morning', style: TextStyle(fontSize: 13, color: darkText, fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // About This Product
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: const [
                                    Icon(Icons.eco_outlined, color: primaryGreen, size: 20),
                                    SizedBox(width: 8),
                                    Text('About This Product', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkText)),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Locally grown pesticide-free beefsteak tomatoes ripened under natural sunlight. Crisp texture with rich balanced sweetness and acidity, perfect for fresh salads, sauces, and daily cooking.',
                                  style: TextStyle(fontSize: 14, color: greyText, height: 1.5),
                                ),
                                const SizedBox(height: 16),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _buildChip(Icons.eco_outlined, 'Pesticide-Free'),
                                    _buildChip(Icons.park_outlined, '100% Organic Soil'),
                                    _buildChip(Icons.verified_outlined, 'Non-GMO'),
                                    _buildChip(Icons.pan_tool_outlined, 'Hand-Picked'),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Farmer Profile
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('GROWN WITH CARE BY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: greyText, letterSpacing: 1.0)),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(10)),
                                      child: Row(
                                        children: const [
                                          Icon(Icons.verified_outlined, size: 12, color: primaryGreen),
                                          SizedBox(width: 4),
                                          Text('Certified Grower', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: darkText)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    const CircleAvatar(radius: 24, backgroundColor: Color(0xFFE5E7EB), child: Icon(Icons.person, color: Colors.grey)),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(widget.product?['farmerName'] ?? 'Green Valley Farm', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkText)),
                                          const SizedBox(height: 2),
                                          const Text('Tariq Mehmood (Farmer since 2012)', style: TextStyle(fontSize: 12, color: greyText)),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: const [
                                              Icon(Icons.star_border, size: 12, color: Colors.orange),
                                              SizedBox(width: 4),
                                              Text('4.8', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: darkText)),
                                              SizedBox(width: 4),
                                              Text('• 120 orders completed', style: TextStyle(fontSize: 11, color: greyText)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(8)),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.location_on_outlined, size: 16, color: primaryGreen),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: RichText(
                                          text: const TextSpan(
                                            style: TextStyle(fontSize: 12, color: darkText),
                                            children: [
                                              TextSpan(text: 'Karachi Farmers Market (Stall 14B) '),
                                              TextSpan(text: '• 2.4 km away', style: TextStyle(fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  height: 40,
                                  child: ElevatedButton(
                                      onPressed: () {
                                        final farmerName = widget.product?['farmerName'] ?? '';
                                        final farmerData = DummyData.popularFarmers.firstWhere(
                                          (f) => f['name'] == farmerName, 
                                          orElse: () => <String, dynamic>{
                                            'id': 'f0',
                                            'name': farmerName,
                                            'rating': '4.5',
                                            'reviews': '0 reviews',
                                            'location': 'Local Market',
                                            'isFollowing': false,
                                          }
                                        );
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (_) => FarmerProfileScreen(farmer: farmerData)),
                                        ).then((_) => setState(() {}));
                                      },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFE5E7EB),
                                      foregroundColor: primaryGreen,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: const [
                                        Text('View Farm Profile', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                        SizedBox(width: 8),
                                        Icon(Icons.arrow_forward, size: 16),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Pickup Information
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: const BoxDecoration(color: Color(0xFFE8F5E9), shape: BoxShape.circle),
                                  child: const Icon(Icons.storefront, color: primaryGreen, size: 20),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Pickup Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkText)),
                                      const SizedBox(height: 6),
                                      RichText(
                                        text: const TextSpan(
                                          style: TextStyle(fontSize: 13, color: greyText, height: 1.4),
                                          children: [
                                            TextSpan(text: 'Available for pickup '),
                                            TextSpan(text: 'Today from 10:00 AM - 6:00 PM', style: TextStyle(fontWeight: FontWeight.bold, color: darkText)),
                                            TextSpan(text: ' at Karachi Farmers Market Hub.'),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

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
      ),
      
      // Bottom Floating Bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Quantity Selector
                  Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        IconButton(icon: const Icon(Icons.remove, size: 20), onPressed: _decrement),
                        SizedBox(
                          width: 40,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('$_quantity', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: darkText, height: 1.0)),
                              Text(widget.product?['unit']?.replaceAll('/', '')?.trim() ?? 'kg', style: const TextStyle(fontSize: 10, color: greyText)),
                            ],
                          ),
                        ),
                        IconButton(icon: const Icon(Icons.add, size: 20), onPressed: _increment),
                      ],
                    ),
                  ),
                  
                  // Total Price
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Total Price', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: greyText)),
                      Text('Rs. ${_pricePerUnit * _quantity}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: primaryGreen)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    // Find product and add to cart
                    if (widget.product != null) {
                      int index = DummyData.cart.indexWhere((p) => p['id'] == widget.product!['id']);
                      if (index != -1) {
                        DummyData.cart[index]['quantity'] = (DummyData.cart[index]['quantity'] as int) + _quantity;
                      } else {
                        Map<String, dynamic> cartItem = Map.from(widget.product!);
                        cartItem['quantity'] = _quantity;
                        DummyData.cart.add(cartItem);
                      }
                    }
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Added $_quantity ${widget.product?['title'] ?? 'Tomatoes'} to Cart!')));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.shopping_basket_outlined, size: 20),
                      SizedBox(width: 8),
                      Text('Add to Cart', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF2E7D32)),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
        ],
      ),
    );
  }
}











