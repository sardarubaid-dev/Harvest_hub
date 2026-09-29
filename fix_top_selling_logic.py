with open('lib/screens/customer/customer_home_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Add the sorting logic right after filteredProducts is computed
import re
pattern = r"(\s+final List<Map<String, dynamic>> filteredProducts = availableProducts\.where\(\(p\) \{.*?\}\)\.toList\(\);)"
replacement = r"\1\n\n    // Top Selling Logic: Sort by lowest available quantity to simulate fast-moving products\n    filteredProducts.sort((a, b) {\n      double qA = (a['quantity'] ?? 0.0) as double;\n      double qB = (b['quantity'] ?? 0.0) as double;\n      return qA.compareTo(qB);\n    });"

content = re.sub(pattern, replacement, content, flags=re.DOTALL)

with open('lib/screens/customer/customer_home_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
print("Added sorting logic")
