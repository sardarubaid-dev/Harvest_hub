import re

with open('lib/models/order_model.dart', 'r', encoding='utf-8') as f:
    c = f.read()

# Add deliveryAddress to fields
c = c.replace('final String paymentMethod;', 'final String paymentMethod;\n  final String? deliveryAddress;')

# Add to constructor
c = c.replace('required this.paymentMethod,', 'required this.paymentMethod,\n    this.deliveryAddress,')

# Add to fromMap
c = c.replace("paymentMethod: map['paymentMethod'] ?? map['Payment_Method'] ?? 'Cash',", "paymentMethod: map['paymentMethod'] ?? map['Payment_Method'] ?? 'Cash',\n      deliveryAddress: map['deliveryAddress'] ?? map['Delivery_Address'],")

# Add to toMap
c = c.replace("'paymentMethod': paymentMethod,", "'paymentMethod': paymentMethod,\n      'deliveryAddress': deliveryAddress,\n      'Delivery_Address': deliveryAddress,")

# Add to copyWith signature
c = c.replace('String? paymentMethod,', 'String? paymentMethod,\n    String? deliveryAddress,')

# Add to copyWith return
c = c.replace('paymentMethod: paymentMethod ?? this.paymentMethod,', 'paymentMethod: paymentMethod ?? this.paymentMethod,\n      deliveryAddress: deliveryAddress ?? this.deliveryAddress,')

with open('lib/models/order_model.dart', 'w', encoding='utf-8') as f:
    f.write(c)
