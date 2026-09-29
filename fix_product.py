with open('lib/screens/customer/product_reviews_widget.dart', 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace('        updatedAt: DateTime.now(),\n', '')

with open('lib/screens/customer/product_reviews_widget.dart', 'w', encoding='utf-8') as f:
    f.write(content)
print('Fixed product_reviews_widget.dart')
