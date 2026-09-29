import re

file_path = 'lib/screens/customer/products_screen.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Add import
if "import '../shared/product_card_widget.dart';" not in content:
    content = content.replace("import 'product_detail_screen.dart';", "import 'product_detail_screen.dart';\nimport '../shared/product_card_widget.dart';")

# Find the inline return GestureDetector(
# The inline card starts at `return GestureDetector(` and ends at the end of `itemBuilder`.
# The builder is:
# itemBuilder: (context, index) {
#   final data = products[index];
#   return GestureDetector( ... );
# },
import re

pattern = r'itemBuilder:\s*\(context,\s*index\)\s*\{\s*final\s*data\s*=\s*products\[index\];\s*return\s*GestureDetector\(.*?\);[\s\n]*\},'
match = re.search(pattern, content, re.DOTALL)
if match:
    # Wait, the inline card is massive. A regex with .*? might be too slow or hit limits.
    pass

