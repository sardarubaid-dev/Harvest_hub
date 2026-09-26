import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import '../models/cart_item_model.dart';
import '../models/order_model.dart';

class CartProvider with ChangeNotifier {
  final Map<String, CartItemModel> _items = {};

  Map<String, CartItemModel> get items => {..._items};

  int get itemCount => _items.length;

  double get totalAmount {
    double total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.subtotal;
    });
    return total;
  }

  void addItem(ProductModel product, {double quantity = 1.0}) {
    if (product.quantity <= 0) return;

    if (_items.containsKey(product.id)) {
      double currentQty = _items[product.id]!.quantity;
      double newQty = currentQty + quantity;
      if (newQty > product.quantity) {
        newQty = product.quantity;
      }
      _items.update(
        product.id,
        (existing) => CartItemModel(
          product: product,
          quantity: newQty,
        ),
      );
    } else {
      double initialQty = quantity > product.quantity ? product.quantity : quantity;
      _items.putIfAbsent(
        product.id,
        () => CartItemModel(
          product: product,
          quantity: initialQty,
        ),
      );
    }
    notifyListeners();
  }

  void updateQuantity(String productId, double quantity) {
    if (!_items.containsKey(productId)) return;

    if (quantity <= 0) {
      _items.remove(productId);
    } else {
      CartItemModel item = _items[productId]!;
      double maxAllowed = item.product.quantity;
      double finalQty = quantity > maxAllowed ? maxAllowed : quantity;

      _items.update(
        productId,
        (existing) => CartItemModel(
          product: existing.product,
          quantity: finalQty,
        ),
      );
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  List<OrderItem> toOrderItems() {
    return _items.values.map((item) {
      return OrderItem(
        productId: item.product.id,
        farmerId: item.product.farmerId,
        productName: item.product.name,
        price: item.product.price,
        quantity: item.quantity,
        unit: item.product.unit,
        imageUrl: item.product.imageUrl,
      );
    }).toList();
  }
}
