with open('lib/screens/customer/product_detail_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

old_block = """                                      final farmerName =
                                          widget.product?['farmerName'] ?? '';
                                      final farmerData = <String, dynamic>{
                                        'id': 'f0',
                                        'name': farmerName,"""

new_block = """                                      final p = widget.product;
                                      final farmerName = p?['farmerName'] ?? p?['Farmer_Name'] ?? 'Farm';
                                      final farmerId = p?['farmerId'] ?? p?['Farmer_Id'] ?? 'f0';
                                      final farmerData = <String, dynamic>{
                                        'id': farmerId,
                                        'name': farmerName,"""

if old_block in content:
    content = content.replace(old_block, new_block)
    with open('lib/screens/customer/product_detail_screen.dart', 'w', encoding='utf-8') as f:
        f.write(content)
    print("Updated farmerData in product_detail_screen")
else:
    print("Block not found!")
