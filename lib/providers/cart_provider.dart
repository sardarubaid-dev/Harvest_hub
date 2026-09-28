import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartProvider with ChangeNotifier {
  List<dynamic> _cartItems = [];

  List<dynamic> get items => _cartItems;
  int get itemCount => _cartItems.length;

  CartProvider() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _subscribeToCart(user.uid);
      } else {
        _cartItems = [];
        notifyListeners();
      }
    });
  }

  String? _currentUid;

  void _subscribeToCart(String uid) {
    _currentUid = uid;
    FirebaseFirestore.instance
        .collection('carts')
        .doc(uid)
        .snapshots()
        .listen((doc) {
      if (doc.exists) {
        _cartItems = List<dynamic>.from(doc.data()?['items'] ?? []);
        notifyListeners();
      } else {
        _cartItems = [];
        notifyListeners();
      }
    });
  }

  Future<void> clearCart() async {
    final uid = _currentUid ?? FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await FirebaseFirestore.instance.collection('carts').doc(uid).set({
      'userId': uid,
      'items': [],
      'updatedAt': FieldValue.serverTimestamp(),
    });
    _cartItems = [];
    notifyListeners();
  }
}
