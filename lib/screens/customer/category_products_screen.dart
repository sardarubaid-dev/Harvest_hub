import 'package:flutter/material.dart';
import '../../core/dummy_data.dart';
import 'product_detail_screen.dart';

class CategoryProductsScreen extends StatelessWidget {
  final String categoryName;

  const CategoryProductsScreen({Key? key, required this.categoryName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF2E7D32);
    const Color darkText = Color(0xFF1F2937);
    const Color greyText = Color(0xFF6B7280);
    const Color background = Color(0xFFF9FBF9);

    // Filter products from dummy data based on category name
    final products = DummyData.freshProducts.where((p) {
      return p['category'].toString().toLowerCase() == categoryName.toLowerCase();
    }).toList();
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: darkText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          categoryName,
          style: const TextStyle(color: darkText, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: products.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'No products found in $categoryName',
                    style: const TextStyle(fontSize: 16, color: greyText),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.65,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final data = products[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailScreen(product: data),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            Container(
                              height: 100,
                              decoration: BoxDecoration(
                                color: data['imageColor'],
                                borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                              ),
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                child: (data['imageUrl'] != null && data['imageUrl'].toString().isNotEmpty)
                                    ? Image.network(data['imageUrl'], fit: BoxFit.cover, width: double.infinity, height: double.infinity)
                                    : Center(child: Icon(Icons.image, size: 40, color: Colors.black.withOpacity(0.2))),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                child: Icon(
                                  data['isFavorite'] ? Icons.favorite : Icons.favorite_border,
                                  size: 16,
                                  color: data['isFavorite'] ? Colors.red : const Color(0xFF6B7280),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 8,
                              left: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                                child: Text(data['stockBadge'], style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: primaryGreen)),
                              ),
                            ),
                          ],
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(data['category'], style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: greyText, letterSpacing: 0.5)),
                                const SizedBox(height: 2),
                                Text(data['title'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: darkText), maxLines: 1, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Expanded(child: Text(data['farmerName'], style: const TextStyle(fontSize: 10, color: Color(0xFF4B5563)), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                    const Icon(Icons.verified, size: 10, color: primaryGreen),
                                  ],
                                ),
                                const Spacer(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Price', style: TextStyle(fontSize: 9, color: greyText)),
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text('Rs. ${data['price']}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: darkText)),
                                            Text(data['unit'], style: const TextStyle(fontSize: 9, color: greyText)),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: const BoxDecoration(color: primaryGreen, shape: BoxShape.circle),
                                      child: const Icon(Icons.add, color: Colors.white, size: 14),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}


