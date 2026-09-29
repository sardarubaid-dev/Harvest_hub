with open('lib/screens/customer/customer_home_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

import re

# We will just replace ALL of them back to spaceBetween
# And then apply it ONLY to the category Column again!

content = content.replace("mainAxisAlignment: MainAxisAlignment.center,\n                      children: [", "mainAxisAlignment: MainAxisAlignment.spaceBetween,\n                      children: [")

# Now re-apply center to the category Column
cat_col = """padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: ["""
cat_col_fixed = """padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: ["""
content = content.replace(cat_col, cat_col_fixed)

with open('lib/screens/customer/customer_home_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
print("Reverted accidental spaceBetween replacements")
