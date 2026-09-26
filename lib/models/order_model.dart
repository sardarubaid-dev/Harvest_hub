class OrderItem {
  final String productId;
  final String farmerId;
  final String productName;
  final double price;
  final double quantity;
  final String unit;
  final String? imageUrl;

  OrderItem({
    required this.productId,
    required this.farmerId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.unit,
    this.imageUrl,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'] ?? map['Product_Id'] ?? '',
      farmerId: map['farmerId'] ?? map['Farmer_Id'] ?? '',
      productName: map['productName'] ?? map['Item_Name'] ?? '',
      price: (map['price'] ?? map['Price'] ?? 0).toDouble(),
      quantity: (map['quantity'] ?? map['Quantity'] ?? 0).toDouble(),
      unit: map['unit'] ?? map['Unit'] ?? 'kg',
      imageUrl: map['imageUrl'] ?? map['Image_Url'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'Product_Id': productId,
      'farmerId': farmerId,
      'Farmer_Id': farmerId,
      'productName': productName,
      'Item_Name': productName,
      'price': price,
      'Price': price,
      'quantity': quantity,
      'Quantity': quantity,
      'unit': unit,
      'Unit': unit,
      'imageUrl': imageUrl,
      'Image_Url': imageUrl,
    };
  }
}

class OrderModel {
  final String id;
  final String customerId;
  final String? customerName;
  final String? customerPhone;
  final String? farmerId;
  final List<OrderItem> items;
  final double totalAmount;
  final String? pickupSlotId;
  final String? pickupSlotTime;
  final String? marketId;
  final String status;
  final String paymentMethod;
  final String? cancellationReason;
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.customerId,
    this.customerName,
    this.customerPhone,
    this.farmerId,
    required this.items,
    required this.totalAmount,
    this.pickupSlotId,
    this.pickupSlotTime,
    this.marketId,
    required this.status,
    required this.paymentMethod,
    this.cancellationReason,
    required this.createdAt,
  });

  factory OrderModel.fromMap(String id, Map<String, dynamic> map) {
    return OrderModel(
      id: id,
      customerId: map['customerId'] ?? map['Customer_Id'] ?? '',
      customerName: map['customerName'] ?? map['Customer_Name'],
      customerPhone: map['customerPhone'] ?? map['Customer_Phone'],
      farmerId: map['farmerId'] ?? map['Farmer_Id'],
      items: (map['items'] as List<dynamic>? ?? map['Items_JSON'] as List<dynamic>? ?? [])
          .map((item) => OrderItem.fromMap(Map<String, dynamic>.from(item)))
          .toList(),
      totalAmount: (map['totalAmount'] ?? map['Total_Price'] ?? map['totalPrice'] ?? 0).toDouble(),
      pickupSlotId: map['pickupSlotId'] ?? map['Pickup_Slot_Id'],
      pickupSlotTime: map['pickupSlotTime'] ?? map['Pickup_Slot_Time'],
      marketId: map['marketId'] ?? map['Market_Id'],
      status: map['status'] ?? map['Status'] ?? 'Pending',
      paymentMethod: map['paymentMethod'] ?? map['Payment_Method'] ?? 'Simulated Checkout',
      cancellationReason: map['cancellationReason'] ?? map['Cancellation_Reason'],
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'Customer_Id': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'farmerId': farmerId,
      'Farmer_Id': farmerId,
      'items': items.map((item) => item.toMap()).toList(),
      'Items_JSON': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'Total_Price': totalAmount,
      'pickupSlotId': pickupSlotId,
      'pickupSlotTime': pickupSlotTime,
      'Pickup_Slot_Time': pickupSlotTime,
      'marketId': marketId,
      'status': status,
      'Status': status,
      'paymentMethod': paymentMethod,
      'cancellationReason': cancellationReason,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  OrderModel copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? farmerId,
    List<OrderItem>? items,
    double? totalAmount,
    String? pickupSlotId,
    String? pickupSlotTime,
    String? marketId,
    String? status,
    String? paymentMethod,
    String? cancellationReason,
    DateTime? createdAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      farmerId: farmerId ?? this.farmerId,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      pickupSlotId: pickupSlotId ?? this.pickupSlotId,
      pickupSlotTime: pickupSlotTime ?? this.pickupSlotTime,
      marketId: marketId ?? this.marketId,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}