with open('c:/Users/Dr.pc/Desktop/harvest_hub/lib/screens/farmer/farmer_inventory_tab.dart', 'r', encoding='utf-8') as f:
    text = f.read()

# Update _showAddProductModal signature
text = text.replace('void _showAddProductModal(BuildContext context, String farmerId, String farmerName) {', 
                    'void _showAddProductModal(BuildContext context, String farmerId, String farmerName, {ProductModel? product}) {')

# Pass product to _AddProductModal
text = text.replace('_AddProductModal(farmerId: farmerId, farmerName: farmerName)', 
                    '_AddProductModal(farmerId: farmerId, farmerName: farmerName, product: product)')

# Fix the edit button to pass the product
text = text.replace('_showAddProductModal(context, farmerId, farmerName), // Ideally pass product for editing', 
                    '_showAddProductModal(context, farmerId, farmerName, product: product),')

# Update _AddProductModal properties
text = text.replace('''class _AddProductModal extends StatefulWidget {
  final String farmerId;
  final String farmerName;

  const _AddProductModal({required this.farmerId, required this.farmerName});''', 
                    '''class _AddProductModal extends StatefulWidget {
  final String farmerId;
  final String farmerName;
  final ProductModel? product;

  const _AddProductModal({required this.farmerId, required this.farmerName, this.product});''')

with open('c:/Users/Dr.pc/Desktop/harvest_hub/lib/screens/farmer/farmer_inventory_tab.dart', 'w', encoding='utf-8') as f:
    f.write(text)