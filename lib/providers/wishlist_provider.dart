import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WishlistProvider with ChangeNotifier {
  List<String> _wishlistIds = [];
  List<String> get wishlistIds => _wishlistIds;

  WishlistProvider() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _subscribeToWishlist(user.uid);
      } else {
        _wishlistIds = [];
        notifyListeners();
      }
    });
  }

  void _subscribeToWishlist(String uid) {
    FirebaseFirestore.instance
        .collection('customers')
        .doc(uid)
        .snapshots()
        .listen((doc) {
      if (doc.exists) {
        _wishlistIds = List<String>.from(doc.data()?['wishlist'] ?? []);
        notifyListeners();
      }
    });
  }

  bool isFavorite(String productId) {
    return _wishlistIds.contains(productId);
  }

  Future<void> toggleWishlist(String productId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (_wishlistIds.contains(productId)) {
      _wishlistIds.remove(productId);
    } else {
      _wishlistIds.add(productId);
    }
    notifyListeners(); // Optimistic update

    final docRef = FirebaseFirestore.instance.collection('customers').doc(user.uid);
    final doc = await docRef.get();
    if (doc.exists) {
      List<String> current = List<String>.from(doc.data()?['wishlist'] ?? []);
      if (current.contains(productId)) {
        current.remove(productId);
      } else {
        current.add(productId);
      }
      await docRef.update({'wishlist': current});
    }
  }
}
