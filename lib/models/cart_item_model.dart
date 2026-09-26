import 'product_model.dart';

class CartItemModel {
  final ProductModel product;
  final double quantity;

  CartItemModel({required this.product, required this.quantity});

  double get subtotal => product.price * quantity;

  CartItemModel copyWith({ProductModel? product, double? quantity}) {
    return CartItemModel(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'product': product.toMap(),
      'productId': product.id,
      'quantity': quantity,
    };
  }
}
