with open('lib/screens/customer/products_screen.dart', 'r', encoding='utf-8') as f:
    lines = f.readlines()

new_lines = lines[:177] + ['                        final data = products[index];\n                        return ProductCard(data: data);\n'] + lines[428:]

content = ''.join(new_lines)
if "import '../shared/product_card_widget.dart';" not in content:
    content = content.replace("import 'product_detail_screen.dart';", "import 'product_detail_screen.dart';\nimport '../shared/product_card_widget.dart';")

with open('lib/screens/customer/products_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
print("Done")
