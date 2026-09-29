with open('lib/screens/admin/admin_reviews_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace('r.customerName', 'r.userName')

with open('lib/screens/admin/admin_reviews_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
print('Fixed admin_reviews_screen.dart')
