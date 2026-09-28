with open('lib/screens/customer/product_detail_screen.dart', 'r', encoding='utf-8') as f:
    c = f.read()

c = c.replace("Widget build(BuildContext context) {", "Widget build(BuildContext context) {\n    final p = widget.product;")
c = c.replace("widget.product != null ? widget.product?['id']?.toString() : null;", "p != null ? p['id']?.toString() : null;")
c = c.replace("int.tryParse(p['price'].toString()) ?? 280", "int.tryParse(widget.product?['price']?.toString() ?? '280') ?? 280")

with open('lib/screens/customer/product_detail_screen.dart', 'w', encoding='utf-8') as f:
    f.write(c)
