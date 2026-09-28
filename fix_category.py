with open('lib/screens/customer/category_products_screen.dart', 'r', encoding='utf-8') as f:
    c = f.read()

c = c.replace("data['isFavorite']", "(data['isFavorite'] as bool? ?? false)")
c = c.replace("data['stockBadge']", "data['stockBadge'].toString()")
c = c.replace("data['category']", "data['category'].toString()")
c = c.replace("data['title']", "data['title'].toString()")
c = c.replace("data['farmerName']", "data['farmerName'].toString()")
c = c.replace("data['unit']", "data['unit'].toString()")
c = c.replace("data['price']", "data['price'].toString()")
c = c.replace("data['model'] as ProductModel", "data['productModel'] as ProductModel")

with open('lib/screens/customer/category_products_screen.dart', 'w', encoding='utf-8') as f:
    f.write(c)
print('Done')
