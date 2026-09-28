import re

with open('lib/screens/customer/cart_screen.dart', 'r', encoding='utf-8') as f:
    c = f.read()

# The block to remove starts around "const SizedBox(height: 12)," and ends before the next "const Divider(height: 32" or something similar.
# Let's find exactly what to remove by using regex that looks for "Marketplace Service Fee" and deletes the whole Row enclosing it.

# Specifically, we want to remove:
# const SizedBox(height: 12),
# Row(
#   mainAxisAlignment: MainAxisAlignment.spaceBetween,
#   children: [
#     Row(
#       children: const [
#         Text('Marketplace Service Fee',
# ...
#     const Text('Rs. 20', ...),
#   ],
# ),

pattern = re.compile(r'const\s*SizedBox\(height:\s*12\),\s*Row\(\s*mainAxisAlignment:\s*MainAxisAlignment\.spaceBetween,\s*children:\s*\[\s*Row\(\s*children:\s*const\s*\[\s*Text\(\s*\'Marketplace Service Fee\'.*?const\s*Text\(\s*\'Rs\. 20\',.*?\),\s*\]\s*,\s*\),', re.DOTALL)

c, count = pattern.subn('', c)
print(f"Replaced {count} instances.")

with open('lib/screens/customer/cart_screen.dart', 'w', encoding='utf-8') as f:
    f.write(c)
