import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';
import '../models/customer_model.dart';
import '../models/farmer_model.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../models/category_model.dart';
import '../models/market_model.dart';
import '../models/pickup_slot_model.dart';
import '../models/notification_model.dart';
import '../models/review_model.dart';
import '../models/banner_model.dart';
import '../models/offer_model.dart';
import '../models/app_config_model.dart';
import '../models/audit_log_model.dart';


class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _usersRef => _firestore.collection('users');
  CollectionReference get _customersRef => _firestore.collection('customers');
  CollectionReference get _farmersRef => _firestore.collection('farmers');
  CollectionReference get _productsRef => _firestore.collection('products');
  CollectionReference get _ordersRef => _firestore.collection('orders');
  CollectionReference get _categoriesRef => _firestore.collection('categories');
  CollectionReference get _marketsRef =>
      _firestore.collection('farmers_markets');
  CollectionReference get _pickupSlotsRef =>
      _firestore.collection('pickup_slots');
  CollectionReference get _notificationsRef =>
      _firestore.collection('notifications');
  CollectionReference get _reviewsRef => _firestore.collection('reviews');

  Stream<UserModel?> streamUser(String uid) {
    return _usersRef.doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        return UserModel.fromMap(uid, doc.data() as Map<String, dynamic>);
      }
      return null;
    });
  }

  Future<void> updateUserProfile({
    required String uid,
    required String name,
    required String phone,
    required String address,
  }) async {
    await _usersRef.doc(uid).update({
      'name': name,
      'phone': phone,
      'address': address,
    });
  }

  Future<void> toggleUserActiveStatus(String uid, bool isActive) async {
    await _usersRef.doc(uid).update({'isActive': isActive});
  }

  Stream<List<UserModel>> streamAllUsers() {
    return _usersRef.snapshots().map((snapshot) {
      return snapshot.docs
          .map(
            (doc) =>
                UserModel.fromMap(doc.id, doc.data() as Map<String, dynamic>),
          )
          .toList();
    });
  }

  Stream<List<FarmerModel>> streamAllFarmers() {
    return _farmersRef.snapshots().map((snapshot) {
      return snapshot.docs
          .map(
            (doc) =>
                FarmerModel.fromMap(doc.id, doc.data() as Map<String, dynamic>),
          )
          .toList();
    });
  }

  Future<FarmerModel?> getFarmerByUserId(String userId) async {

    QuerySnapshot snap = await _farmersRef
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();
    if (snap.docs.isNotEmpty) {
      return FarmerModel.fromMap(
        snap.docs.first.id,
        snap.docs.first.data() as Map<String, dynamic>,
      );
    }
    return null;
  }

  Future<FarmerModel?> getFarmerById(String farmerId) async {
    DocumentSnapshot doc = await _farmersRef.doc(farmerId).get();
    if (doc.exists) {
      return FarmerModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<void> updateFarmerProfile({
    required String farmerId,
    required String farmName,
    required String description,
    required String location,
    required String contactNumber,
    String? marketId,
    double? latitude,
    double? longitude,
    String? profileImageUrl,
  }) async {
    Map<String, dynamic> data = {
      'farmName': farmName,
      'businessName': farmName,
      'description': description,
      'location': location,
      'contactNumber': contactNumber,
    };
    if (marketId != null) data['marketId'] = marketId;
    if (latitude != null) data['latitude'] = latitude;
    if (longitude != null) data['longitude'] = longitude;
    if (profileImageUrl != null) data['profileImageUrl'] = profileImageUrl;

    await _farmersRef.doc(farmerId).update(data);
  }

  Future<void> toggleFarmerApproval(String farmerId, bool isApproved) async {
    await _farmersRef.doc(farmerId).update({'isApproved': isApproved});
  }

  Future<void> toggleFollowFarmer(
    String customerUserId,
    String farmerId,
  ) async {
    DocumentSnapshot customerDoc = await _customersRef
        .doc(customerUserId)
        .get();
    if (customerDoc.exists) {
      List<String> followed = List<String>.from(
        customerDoc.get('followedFarmers') ?? [],
      );
      if (followed.contains(farmerId)) {
        followed.remove(farmerId);
      } else {
        followed.add(farmerId);
      }
      await _customersRef.doc(customerUserId).update({
        'followedFarmers': followed,
      });
    }
  }

  Stream<List<CategoryModel>> streamCategories() {
    return _categoriesRef.snapshots().map((snapshot) {
      return snapshot.docs
          .map(
            (doc) => CategoryModel.fromMap(
              doc.id,
              doc.data() as Map<String, dynamic>,
            ),
          )
          .toList();
    });
  }

  Future<void> addCategory(CategoryModel category) async {
    DocumentReference ref = _categoriesRef.doc();
    await ref.set(category.toMap());
  }

  Future<void> updateCategory(CategoryModel category) async {
    await _categoriesRef.doc(category.id).update(category.toMap());
  }

  Future<void> deleteCategory(String categoryId) async {
    await _categoriesRef.doc(categoryId).delete();
  }

  Stream<List<MarketModel>> streamMarkets() {
    return _marketsRef.snapshots().map((snapshot) {
      return snapshot.docs
          .map(
            (doc) =>
                MarketModel.fromMap(doc.id, doc.data() as Map<String, dynamic>),
          )
          .toList();
    });
  }

  Future<void> addMarket(MarketModel market) async {
    DocumentReference ref = _marketsRef.doc();
    await ref.set(market.toMap());
  }

  Future<void> updateMarket(MarketModel market) async {
    await _marketsRef.doc(market.id).update(market.toMap());
  }

  Future<void> deleteMarket(String marketId) async {
    await _marketsRef.doc(marketId).delete();
  }

  Stream<List<ProductModel>> streamAllProducts() {
    return _productsRef.snapshots().map((snapshot) {
      return snapshot.docs
          .map(
            (doc) => ProductModel.fromMap(
              doc.id,
              doc.data() as Map<String, dynamic>,
            ),
          )
          .toList();
    });
  }

  Stream<List<ProductModel>> streamProductsByFarmer(String farmerId) {
    return _productsRef.where('farmerId', isEqualTo: farmerId).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs
          .map(
            (doc) => ProductModel.fromMap(
              doc.id,
              doc.data() as Map<String, dynamic>,
            ),
          )
          .toList();
    });
  }

  Stream<List<ProductModel>> streamProductsByCategory(String categoryId) {
    return _productsRef
        .where('categoryId', isEqualTo: categoryId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map(
                (doc) => ProductModel.fromMap(
                  doc.id,
                  doc.data() as Map<String, dynamic>,
                ),
              )
              .toList();
        });
  }

  Stream<List<ProductModel>> streamDealsOfTheDay() {
    return _productsRef
        .where('isDealOfTheDay', isEqualTo: true)
        .where('quantity', isGreaterThan: 0)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map(
                (doc) => ProductModel.fromMap(
                  doc.id,
                  doc.data() as Map<String, dynamic>,
                ),
              )
              .toList();
        });
  }

  Future<void> addProduct(ProductModel product) async {
    DocumentReference ref = _productsRef.doc();
    ProductModel newProduct = product.copyWith(id: ref.id);
    await ref.set(newProduct.toMap());
  }

  Future<void> updateProduct(ProductModel product) async {
    double oldQty = 0;
    DocumentSnapshot doc = await _productsRef.doc(product.id).get();
    if (doc.exists) {
      oldQty = (doc.get('quantity') ?? 0).toDouble();
    }

    await _productsRef.doc(product.id).update(product.toMap());

    if (oldQty == 0 && product.quantity > 0) {
      await _triggerRestockNotifications(product);
    }
  }

  Future<void> deleteProduct(String productId) async {
    await _productsRef.doc(productId).delete();
  }

  Future<void> updateProductStock(String productId, double newQuantity) async {
    bool isAvail = newQuantity > 0;
    await _productsRef.doc(productId).update({
      'quantity': newQuantity,
      'Stock_Qty': newQuantity,
      'isAvailable': isAvail,
    });
  }

  Future<void> _triggerRestockNotifications(ProductModel product) async {
    QuerySnapshot customersSnap = await _customersRef.get();
    for (var doc in customersSnap.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      List<String> wishlist = List<String>.from(data['wishlist'] ?? []);
      List<String> followed = List<String>.from(data['followedFarmers'] ?? []);

      if (wishlist.contains(product.id) ||
          followed.contains(product.farmerId)) {
        await sendNotification(
          userId: doc.id,
          title: "Item Restocked!",
          message:
              "${product.name} is now back in stock with ${product.quantity} ${product.unit} available!",
          type: "restock",
        );
      }
    }
  }

  List<ProductModel> filterProducts({
    required List<ProductModel> products,
    String? query,
    String? categoryId,
    String? marketId,
    String? farmerId,
  }) {
    return products.where((p) {
      if (categoryId != null && categoryId.isNotEmpty && categoryId != 'All') {
        if (p.categoryId != categoryId && p.categoryName != categoryId) {
          return false;
        }
      }
      if (farmerId != null && farmerId.isNotEmpty) {
        if (p.farmerId != farmerId) return false;
      }
      if (query != null && query.trim().isNotEmpty) {
        String q = query.trim().toLowerCase();
        bool matchesName = p.name.toLowerCase().contains(q);
        bool matchesCategory = p.categoryName.toLowerCase().contains(q);
        bool matchesDesc = p.description.toLowerCase().contains(q);
        bool matchesFarmer = (p.farmerName ?? '').toLowerCase().contains(q);
        if (!matchesName &&
            !matchesCategory &&
            !matchesDesc &&
            !matchesFarmer) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  Stream<CustomerModel?> streamCustomer(String userId) {

    return _customersRef.doc(userId).snapshots().map((doc) {
      if (doc.exists) {
        return CustomerModel.fromMap(
          userId,
          doc.data() as Map<String, dynamic>,
        );
      }
      return null;
    });
  }

  Future<void> toggleWishlistProduct(
    String customerUserId,
    String productId,
  ) async {
    DocumentSnapshot doc = await _customersRef.doc(customerUserId).get();
    if (doc.exists) {
      List<String> wishlist = List<String>.from(doc.get('wishlist') ?? []);
      if (wishlist.contains(productId)) {
        wishlist.remove(productId);
      } else {
        wishlist.add(productId);
      }
      await _customersRef.doc(customerUserId).update({'wishlist': wishlist});
    }
  }

  Future<OrderModel> placeOrder({
    required String customerId,
    required String customerName,
    required String customerPhone,
    required List<OrderItem> items,
    required double totalAmount,
    String? pickupSlotId,
    String? pickupSlotTime,
    String? marketId,
    String? deliveryAddress,
  }) async {
    for (var item in items) {
      DocumentSnapshot productDoc = await _productsRef
          .doc(item.productId)
          .get();
      if (productDoc.exists) {
        double currentStock = (productDoc.get('quantity') ?? 0).toDouble();
        if (currentStock < item.quantity) {
          throw Exception(
            "Insufficient stock for ${item.productName}. Available: $currentStock",
          );
        }
      }
    }

    for (var item in items) {
      DocumentSnapshot productDoc = await _productsRef
          .doc(item.productId)
          .get();
      if (productDoc.exists) {
        double currentStock = (productDoc.get('quantity') ?? 0).toDouble();
        double newStock = currentStock - item.quantity;
        await updateProductStock(item.productId, newStock < 0 ? 0 : newStock);
      }
    }

    String primaryFarmerId = items.isNotEmpty ? items.first.farmerId : '';

    DocumentReference orderRef = _ordersRef.doc();
    OrderModel newOrder = OrderModel(
      id: orderRef.id,
      customerId: customerId,
      customerName: customerName,
      customerPhone: customerPhone,
      farmerId: primaryFarmerId,
      items: items,
      totalAmount: totalAmount,
      pickupSlotId: pickupSlotId,
      pickupSlotTime: pickupSlotTime,
      marketId: marketId,
      deliveryAddress: deliveryAddress,
      status: 'Pending',
      paymentMethod: 'Simulated Cash on Pickup',
      createdAt: DateTime.now(),
    );

    await orderRef.set(newOrder.toMap());

    await sendNotification(
      userId: customerId,
      title: "Order Placed Successfully! ",
      message:
          "Your order #${newOrder.id.substring(0, 6)} totaling \$${totalAmount.toStringAsFixed(2)} has been placed.",
      type: "order_status",
    );

    if (primaryFarmerId.isNotEmpty) {
      FarmerModel? farmer = await getFarmerById(primaryFarmerId);
      if (farmer != null) {
        await sendNotification(
          userId: farmer.userId,
          title: "New Order Received! ",
          message:
              "You have a new order #${newOrder.id.substring(0, 6)} for \$${totalAmount.toStringAsFixed(2)}.",
          type: "order_status",
        );
      }
    }

    return newOrder;
  }

  Stream<List<OrderModel>> streamCustomerOrders(String customerId) {
    return _ordersRef
        .where('customerId', isEqualTo: customerId)
        .snapshots()
        .map((snapshot) {
          List<OrderModel> orders = snapshot.docs
              .map(
                (doc) => OrderModel.fromMap(
                  doc.id,
                  doc.data() as Map<String, dynamic>,
                ),
              )
              .toList();
          orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return orders;
        });
  }

  Stream<List<OrderModel>> streamFarmerOrders(String farmerId) {
    return _ordersRef.snapshots().map((snapshot) {
      List<OrderModel> orders = [];
      for (var doc in snapshot.docs) {
        OrderModel order = OrderModel.fromMap(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
        bool containsFarmerItems =
            order.items.any((item) => item.farmerId == farmerId) ||
            order.farmerId == farmerId;
        if (containsFarmerItems) {
          orders.add(order);
        }
      }

      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return orders;
    });
  }

  Stream<List<OrderModel>> streamAllOrders() {
    return _ordersRef.snapshots().map((snapshot) {
      List<OrderModel> orders = snapshot.docs
          .map(
            (doc) =>
                OrderModel.fromMap(doc.id, doc.data() as Map<String, dynamic>),
          )
          .toList();
      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return orders;
    });
  }

  Future<void> updateOrderStatus(
    String orderId,
    String status, {
    String? cancellationReason,
  }) async {
    Map<String, dynamic> updateData = {'status': status, 'Status': status};
    if (cancellationReason != null) {
      updateData['cancellationReason'] = cancellationReason;
    }
    await _ordersRef.doc(orderId).update(updateData);

    DocumentSnapshot orderDoc = await _ordersRef.doc(orderId).get();
    if (orderDoc.exists) {
      String customerId = orderDoc.get('customerId') ?? '';
      if (customerId.isNotEmpty) {
        await sendNotification(
          userId: customerId,
          title: "Order Status Updated ",
          message:
              "Order #${orderId.substring(0, 6)} status changed to: $status.",
          type: "order_status",
        );
      }
    }
  }

  Stream<List<PickupSlotModel>> streamPickupSlots({required String marketId}) {
    return _pickupSlotsRef
        .where('marketId', isEqualTo: marketId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map(
                (doc) => PickupSlotModel.fromMap(
                  doc.id,
                  doc.data() as Map<String, dynamic>,
                ),
              )
              .toList();
        });
  }

  Future<void> addPickupSlot(PickupSlotModel slot) async {
    DocumentReference ref = _pickupSlotsRef.doc();
    await ref.set(slot.copyWith(id: ref.id).toMap());
  }

  Future<void> sendNotification({
    required String userId,
    required String title,
    required String message,
    String type = 'system',
  }) async {
    DocumentReference ref = _notificationsRef.doc();
    NotificationModel notif = NotificationModel(
      id: ref.id,
      userId: userId,
      title: title,
      message: message,
      type: type,
      isRead: false,
      createdAt: DateTime.now(),
    );
    await ref.set(notif.toMap());
  }

  Stream<List<NotificationModel>> streamNotifications(String userId) {
    return _notificationsRef.where('userId', isEqualTo: userId).snapshots().map(
      (snapshot) {

        List<NotificationModel> list = snapshot.docs
            .map(
              (doc) => NotificationModel.fromMap(
                doc.id,
                doc.data() as Map<String, dynamic>,
              ),
            )
            .toList();
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return list;
      },
    );
  }

  Stream<List<NotificationModel>> streamUserNotifications(String userId) {
    return streamNotifications(userId);
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    await _notificationsRef.doc(notificationId).update({'isRead': true});
  }

  Future<void> deleteNotification(String notificationId) async {
    await _notificationsRef.doc(notificationId).delete();
  }

  Future<void> markAllNotificationsAsRead(String userId) async {
    QuerySnapshot snap =
        await _notificationsRef.where('userId', isEqualTo: userId).get();
    for (var doc in snap.docs) {
      await doc.reference.update({'isRead': true});
    }
  }

  Stream<List<ReviewModel>> streamProductReviews(String productId) {
    return _reviewsRef
        .where('productId', isEqualTo: productId)
        .where('status', isEqualTo: 'published')
        .snapshots()
        .map((snapshot) {
          List<ReviewModel> reviews = snapshot.docs
              .map((doc) => ReviewModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
              .toList();
          reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return reviews;
        });
  }

  Stream<List<ReviewModel>> streamAllReviews() {
    return _reviewsRef
        .where('status', isEqualTo: 'published')
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ReviewModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
              .toList();
        });
  }

  Stream<List<ReviewModel>> streamFarmerReviews(String farmerId) {
    return _reviewsRef
        .where('farmerId', isEqualTo: farmerId)
        .snapshots()
        .map((snapshot) {
          List<ReviewModel> reviews = snapshot.docs
              .map((doc) => ReviewModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
              .toList();
          reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return reviews;
        });
  }

  Future<void> addReview(ReviewModel review) async {
    final reviewRef = _reviewsRef.doc();
    final newReview = review.copyWith(id: reviewRef.id);
    final productRef = _productsRef.doc(review.productId);

    await _firestore.runTransaction((transaction) async {
      final productDoc = await transaction.get(productRef);
      if (!productDoc.exists) {
        throw Exception("Product not found");
      }

      // Add the review document
      transaction.set(reviewRef, newReview.toMap());

      // Atomically update product aggregates
      final data = productDoc.data() as Map<String, dynamic>;
      final int totalReviews = (data['totalReviews'] ?? 0).toInt();
      final double averageRating = (data['averageRating'] ?? 0.0).toDouble();
      final Map<String, dynamic> breakdown = data['ratingBreakdown'] != null
          ? Map<String, dynamic>.from(data['ratingBreakdown'])
          : {'5': 0, '4': 0, '3': 0, '2': 0, '1': 0};

      final int newTotal = totalReviews + 1;
      final int currentBreakdownCount = (breakdown[review.rating.toString()] ?? 0).toInt();
      breakdown[review.rating.toString()] = currentBreakdownCount + 1;

      // Calculate new average
      final double newAverage = ((averageRating * totalReviews) + review.rating) / newTotal;

      transaction.update(productRef, {
        'totalReviews': newTotal,
        'averageRating': newAverage,
        'ratingBreakdown': breakdown,
      });
    });
  }

  Future<void> toggleHelpfulVote(String reviewId, String userId) async {
    final reviewRef = _reviewsRef.doc(reviewId);
    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(reviewRef);
      if (!doc.exists) return;
      
      final data = doc.data() as Map<String, dynamic>;
      List<String> helpfulUsers = List<String>.from(data['helpfulUserIds'] ?? []);
      int count = (data['helpfulCount'] ?? 0).toInt();

      if (helpfulUsers.contains(userId)) {
        helpfulUsers.remove(userId);
        count = count > 0 ? count - 1 : 0;
      } else {
        helpfulUsers.add(userId);
        count += 1;
      }

      transaction.update(reviewRef, {
        'helpfulUserIds': helpfulUsers,
        'helpfulCount': count,
      });
    });
  }

  Future<void> addFarmerReply(String reviewId, String farmerId, String replyComment) async {
    final reviewRef = _reviewsRef.doc(reviewId);
    final replyMap = {
      'comment': replyComment,
      'repliedAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
    await reviewRef.update({'farmerReply': replyMap});
  }

  Future<void> approveReview(String reviewId) async {
    await _reviewsRef.doc(reviewId).update({'isApproved': true});
  }
  
  Future<void> deleteReview(String reviewId) async {
    await _reviewsRef.doc(reviewId).delete();
  }

  Future<Map<String, dynamic>> getPaginatedReviews({
    required String productId,
    required int limit,
    DocumentSnapshot? startAfter,
  }) async {
    Query query = _reviewsRef
        .where('productId', isEqualTo: productId)
        .where('status', isEqualTo: 'published')
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snap = await query.get();
    final reviews = snap.docs
        .map((doc) => ReviewModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .toList();
    
    return {
      'reviews': reviews,
      'lastDoc': snap.docs.isNotEmpty ? snap.docs.last : null,
    };
  }

  // ===========================================================================
  // FULL-STACK FIRESTORE CART SYSTEM ('carts' collection in Firestore)
  // ===========================================================================

  CollectionReference get _cartsRef => _firestore.collection('carts');

  String _resolveCartDocId(String? uid) {
    if (uid != null && uid.trim().isNotEmpty) {
      return uid.trim();
    }
    return 'guest_cart';
  }

  Map<String, dynamic> _sanitizeCartItemForFirestore(Map<String, dynamic> raw) {
    Color? imgColor = raw['imageColor'] is Color ? raw['imageColor'] as Color : null;
    return {
      'id': (raw['id'] ?? raw['title'] ?? '').toString(),
      'title': (raw['title'] ?? raw['name'] ?? 'Fresh Produce').toString(),
      'category': (raw['category'] ?? 'PRODUCE').toString(),
      'farmerId': (raw['farmerId'] ?? '').toString(),
      'farmerName': (raw['farmerName'] ?? 'Verified Local Farm').toString(),
      'price': (raw['price'] ?? '0').toString().replaceAll(RegExp(r'[^0-9.]'), ''),
      'unit': (raw['unit'] ?? '/ kg').toString(),
      'quantity': (raw['quantity'] is num) ? (raw['quantity'] as num).toInt() : 1,
      'imageUrl': (raw['imageUrl'] ?? '').toString(),
      'stockBadge': (raw['stockBadge'] ?? 'In Stock').toString(),
      'colorValue': imgColor != null ? imgColor.toARGB32() : 0xFFA5D6A7,
    };
  }

  Map<String, dynamic> _hydrateCartItemFromFirestore(Map<String, dynamic> data) {
    final int colorVal = (data['colorValue'] is int)
        ? data['colorValue'] as int
        : 0xFFA5D6A7;
    return {
      'id': (data['id'] ?? data['title'] ?? '').toString(),
      'title': (data['title'] ?? 'Fresh Produce').toString(),
      'category': (data['category'] ?? 'PRODUCE').toString(),
      'farmerId': (data['farmerId'] ?? '').toString(),
      'farmerName': (data['farmerName'] ?? 'Verified Local Farm').toString(),
      'price': (data['price'] ?? '0').toString(),
      'unit': (data['unit'] ?? '/ kg').toString(),
      'quantity': (data['quantity'] is num) ? (data['quantity'] as num).toInt() : 1,
      'imageUrl': (data['imageUrl'] ?? '').toString(),
      'stockBadge': (data['stockBadge'] ?? 'In Stock').toString(),
      'imageColor': Color(colorVal),
    };
  }

  Stream<List<Map<String, dynamic>>> streamCart(String? uid) {
    final String docId = _resolveCartDocId(uid);
    return _cartsRef.doc(docId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) {
        return <Map<String, dynamic>>[];
      }
      final Map<String, dynamic> map = doc.data() as Map<String, dynamic>;
      final List<dynamic> rawList = (map['items'] as List<dynamic>?) ?? [];
      return rawList
          .whereType<Map>()
          .map((e) => _hydrateCartItemFromFirestore(Map<String, dynamic>.from(e)))
          .toList();
    });
  }

  Future<List<Map<String, dynamic>>> getCartOnce(String? uid) async {
    final String docId = _resolveCartDocId(uid);
    final doc = await _cartsRef.doc(docId).get();
    if (!doc.exists || doc.data() == null) return [];
    final Map<String, dynamic> map = doc.data() as Map<String, dynamic>;
    final List<dynamic> rawList = (map['items'] as List<dynamic>?) ?? [];
    return rawList
        .whereType<Map>()
        .map((e) => _hydrateCartItemFromFirestore(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> addToCart({
    required String? uid,
    required Map<String, dynamic> product,
    int quantityDelta = 1,
  }) async {
    final String docId = _resolveCartDocId(uid);
    final DocumentReference docRef = _cartsRef.doc(docId);
    final DocumentSnapshot snap = await docRef.get();

    List<Map<String, dynamic>> currentItems = [];
    if (snap.exists && snap.data() != null) {
      final Map<String, dynamic> data = snap.data() as Map<String, dynamic>;
      final List<dynamic> raw = (data['items'] as List<dynamic>?) ?? [];
      currentItems = raw
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }

    final Map<String, dynamic> sanitized = _sanitizeCartItemForFirestore(product);
    final String targetId = sanitized['id'].toString();
    final String targetTitle = sanitized['title'].toString();

    final int existingIndex = currentItems.indexWhere(
      (item) =>
          (targetId.isNotEmpty && item['id'].toString() == targetId) ||
          item['title'].toString() == targetTitle,
    );

    if (existingIndex != -1) {
      final int currentQty = (currentItems[existingIndex]['quantity'] is num)
          ? (currentItems[existingIndex]['quantity'] as num).toInt()
          : 1;
      currentItems[existingIndex]['quantity'] = currentQty + quantityDelta;
    } else {
      sanitized['quantity'] = quantityDelta;
      currentItems.add(sanitized);
    }

    await docRef.set({
      'userId': docId,
      'updatedAt': FieldValue.serverTimestamp(),
      'items': currentItems,
    });
  }

  Future<void> updateCartItemQuantity({
    required String? uid,
    required String productId,
    required String title,
    required int newQuantity,
  }) async {
    final String docId = _resolveCartDocId(uid);
    final DocumentReference docRef = _cartsRef.doc(docId);
    final DocumentSnapshot snap = await docRef.get();
    if (!snap.exists || snap.data() == null) return;

    final Map<String, dynamic> data = snap.data() as Map<String, dynamic>;
    final List<dynamic> raw = (data['items'] as List<dynamic>?) ?? [];
    final List<Map<String, dynamic>> currentItems = raw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    final int index = currentItems.indexWhere(
      (item) =>
          (productId.isNotEmpty && item['id'].toString() == productId) ||
          item['title'].toString() == title,
    );
    if (index == -1) return;

    if (newQuantity <= 0) {
      currentItems.removeAt(index);
    } else {
      currentItems[index]['quantity'] = newQuantity;
    }

    await docRef.set({
      'userId': docId,
      'updatedAt': FieldValue.serverTimestamp(),
      'items': currentItems,
    });
  }

  Future<void> removeFromCart({
    required String? uid,
    required String productId,
    required String title,
  }) async {
    await updateCartItemQuantity(
      uid: uid,
      productId: productId,
      title: title,
      newQuantity: 0,
    );
  }

  Future<void> clearCart(String? uid) async {
    final String docId = _resolveCartDocId(uid);
    await _cartsRef.doc(docId).set({
      'userId': docId,
      'updatedAt': FieldValue.serverTimestamp(),
      'items': <Map<String, dynamic>>[],
    });
  }

  // ===========================================================================
  // MISSING METHODS FROM MERGE CONFLICT
  // ===========================================================================

  Stream<List<BannerModel>> streamBanners() {
    return _firestore.collection('banners').snapshots().map((snap) =>
        snap.docs.map((doc) => BannerModel.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList());
  }

  Future<void> addBanner(BannerModel banner) async {
    await _firestore.collection('banners').add(banner.toMap());
  }

  Future<void> updateBanner(BannerModel banner) async {
    await _firestore.collection('banners').doc(banner.id).update(banner.toMap());
  }

  Future<void> deleteBanner(String id) async {
    await _firestore.collection('banners').doc(id).delete();
  }

  Future<void> updateFarmer(FarmerModel farmer) async {
    await _farmersRef.doc(farmer.id).set(farmer.toMap(), SetOptions(merge: true));
  }

  Future<void> deleteFarmer(String id) async {
    await _farmersRef.doc(id).delete();
  }

  Future<Map<String, dynamic>> getPaginatedOrders({required int limit, DocumentSnapshot? startAfter}) async {
    Query query = _ordersRef.orderBy('createdAt', descending: true).limit(limit);
    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }
    final snap = await query.get();
    final orders = snap.docs.map((doc) => OrderModel.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList();
    return {
      'orders': orders,
      'lastDoc': snap.docs.isNotEmpty ? snap.docs.last : null,
    };
  }

  Stream<AppConfigModel?> streamAppConfig() {
    return _firestore.collection('config').doc('global').snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return AppConfigModel.fromMap(snap.data() as Map<String, dynamic>);
    });
  }

  Future<void> updateAppConfig(AppConfigModel config) async {
    await _firestore.collection('config').doc('global').set(config.toMap(), SetOptions(merge: true));
  }

  Stream<List<OfferModel>> streamOffers() {
    return _firestore.collection('offers').snapshots().map((snap) =>
        snap.docs.map((doc) => OfferModel.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList());
  }

  Future<void> makeOfferLive(OfferModel offer) async {
    await updateOffer(offer.copyWith(isActive: true));
  }

  Future<void> updateOffer(OfferModel offer) async {
    await _firestore.collection('offers').doc(offer.id).update(offer.toMap());
  }

  Future<void> deleteOffer(String id) async {
    await _firestore.collection('offers').doc(id).delete();
  }

  Future<void> addOffer(OfferModel offer) async {
    await _firestore.collection('offers').add(offer.toMap());
  }

  Future<void> logAdminAction(AuditLogModel log) async {
    await _firestore.collection('auditLogs').add(log.toMap());
  }

  Stream<List<AuditLogModel>> streamAuditLogs() {
    return _firestore.collection('auditLogs')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => AuditLogModel.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList());
  }

  Future<UserModel?> getUser(String uid) async {
    final doc = await _usersRef.doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<void> updateUser(UserModel user) async {
    await _usersRef.doc(user.uid).set(user.toMap(), SetOptions(merge: true));
  }

  Future<void> deleteUser(String uid) async {
    await _usersRef.doc(uid).delete();
  }

  Future<OrderModel?> getOrder(String orderId) async {
    final doc = await _ordersRef.doc(orderId).get();
    if (doc.exists && doc.data() != null) {
      return OrderModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<CustomerModel?> getCustomer(String customerId) async {
    final doc = await _customersRef.doc(customerId).get();
    if (doc.exists && doc.data() != null) {
      return CustomerModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<FarmerModel?> getFarmer(String farmerId) async {
    final doc = await _farmersRef.doc(farmerId).get();
    if (doc.exists && doc.data() != null) {
      return FarmerModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    }
    return null;
  }
}
