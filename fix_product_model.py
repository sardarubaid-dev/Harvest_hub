with open('lib/models/product_model.dart', 'r', encoding='utf-8') as f:
    content = f.read()

old_price = "price: (map['price'] ?? map['Price'] ?? 0).toDouble(),"
new_price = "price: double.tryParse((map['price'] ?? map['Price'] ?? 0).toString()) ?? 0.0,"
content = content.replace(old_price, new_price)

old_qty = "quantity: (map['quantity'] ?? map['Quantity'] ?? 0).toDouble(),"
new_qty = "quantity: double.tryParse((map['quantity'] ?? map['Quantity'] ?? 0).toString()) ?? 0.0,"
content = content.replace(old_qty, new_qty)

old_orig = "originalPrice: map['originalPrice'] != null ? (map['originalPrice'] as num).toDouble() : null,"
new_orig = "originalPrice: map['originalPrice'] != null ? double.tryParse(map['originalPrice'].toString()) : null,"
content = content.replace(old_orig, new_orig)

old_avg = "averageRating: (map['averageRating'] ?? 0).toDouble(),"
new_avg = "averageRating: double.tryParse((map['averageRating'] ?? 0).toString()) ?? 0.0,"
content = content.replace(old_avg, new_avg)

old_tot = "totalReviews: map['totalReviews'] ?? 0,"
new_tot = "totalReviews: int.tryParse((map['totalReviews'] ?? 0).toString()) ?? 0,"
content = content.replace(old_tot, new_tot)

with open('lib/models/product_model.dart', 'w', encoding='utf-8') as f:
    f.write(content)
print("Made ProductModel.fromMap crash-proof")
