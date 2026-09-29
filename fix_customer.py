with open('lib/screens/customer/customer_home_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace('                      updatedAt: DateTime.now(),\n', '')

with open('lib/screens/customer/customer_home_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
print('Fixed customer_home_screen.dart')
