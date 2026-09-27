import re
with open('c:/Users/Dr.pc/Desktop/harvest_hub/lib/screens/farmer/farmer_inventory_tab.dart', 'r', encoding='utf-8') as f:
    text = f.read()

init_state = '''  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      nameController.text = widget.product!.name;
      descController.text = widget.product!.description;
      priceController.text = widget.product!.price.toString();
      quantityController.text = widget.product!.quantityAvailable.toString();
      selectedUnit = widget.product!.unit;
      isOrganic = widget.product!.isOrganic;
      isAvailable = widget.product!.isAvailable;
    }
  }

  final _formKey'''
text = text.replace('  final _formKey', init_state)

if 'bool isAvailable = true;' not in text:
    text = text.replace('bool isOrganic = false;', 'bool isOrganic = false;\n  bool isAvailable = true;')

save_logic = '''      try {
        if (widget.product == null) {
          final product = ProductModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            farmerId: widget.farmerId,
            farmerName: widget.farmerName,
            categoryId: 'cat_1', // Should be dynamic
            name: nameController.text,
            description: descController.text,
            price: double.parse(priceController.text),
            unit: selectedUnit,
            quantityAvailable: double.parse(quantityController.text),
            isOrganic: isOrganic,
            isAvailable: isAvailable,
            createdAt: DateTime.now(),
          );
          await _dbService.addProduct(product);
        } else {
          final product = widget.product!.copyWith(
            name: nameController.text,
            description: descController.text,
            price: double.parse(priceController.text),
            unit: selectedUnit,
            quantityAvailable: double.parse(quantityController.text),
            isOrganic: isOrganic,
            isAvailable: isAvailable,
          );
          await _dbService.updateProduct(product);
        }
        if (mounted) Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error saving product')));
      }'''

text = re.sub(r"      try \{[\s\S]*?if \(mounted\) Navigator\.pop\(context\);[\s\S]*?\} catch \(e\) \{[\s\S]*?\}", save_logic, text)

text = text.replace("const Text('Add New Product'", "Text(widget.product == null ? 'Add New Product' : 'Edit Product'")

with open('c:/Users/Dr.pc/Desktop/harvest_hub/lib/screens/farmer/farmer_inventory_tab.dart', 'w', encoding='utf-8') as f:
    f.write(text)