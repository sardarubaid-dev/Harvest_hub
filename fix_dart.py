import re

file_path = 'lib/screens/customer/customer_home_screen.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace("f'{cartProv.itemCount}'", "'${cartProv.itemCount}'")

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)
print("fixed")
