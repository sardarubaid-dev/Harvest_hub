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
import '../models/audit_log_model.dart';
import '../models/banner_model.dart';
import '../models/offer_model.dart';
import '../models/app_config_model.dart';

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
  CollectionReference get _auditLogsRef => _firestore.collection('audit_logs');
  CollectionReference get _bannersRef => _firestore.collection('banners');
  CollectionReference get _offersRef => _firestore.collection('offers');
  CollectionReference get _appConfigRef => _firestore.collection('app_config');

  Stream<UserModel?> streamUser(String uid) {
    return _usersRef.doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        return UserModel.fromMap(uid, doc.data() as Map<String, dynamic>);
      }
      return null;
    });
  }

  Future<CustomerModel?> getCustomer(String id) async {
    final doc = await _usersRef.doc(id).get();
    if (doc.exists) {
      return CustomerModel.fromMap(id, doc.data() as Map<String, dynamic>);
    }
    // Fallback if there's a separate customers collection
    final custDoc = await _customersRef.doc(id).get();
    if (custDoc.exists) {
      return CustomerModel.fromMap(id, custDoc.data() as Map<String, dynamic>);
    }
    return null;
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

  Future<FarmerModel?> getFarmer(String id) async {
    final doc = await _farmersRef.doc(id).get();
    if (doc.exists) {
      return FarmerModel.fromMap(id, doc.data() as Map<String, dynamic>);
    }
    return null;
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

  Future<void> updateFarmer(FarmerModel farmer) async {
    await _firestore.collection('farmers').doc(farmer.id).update(farmer.toMap());
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

  Future<Map<String, dynamic>> getPaginatedOrders({int limit = 20, DocumentSnapshot? startAfter}) async {
    Query query = _ordersRef.orderBy('createdAt', descending: true).limit(limit);
    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }
    final querySnapshot = await query.get();
    final orders = querySnapshot.docs.map((doc) => OrderModel.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList();
    
    DocumentSnapshot? lastDoc;
    if (querySnapshot.docs.isNotEmpty) {
      lastDoc = querySnapshot.docs.last;
    }
    return {
      'orders': orders,
      'lastDoc': lastDoc,
    };
  }

  Future<OrderModel?> getOrder(String id) async {
    final doc = await _ordersRef.doc(id).get();
    if (doc.exists) {
      return OrderModel.fromMap(id, doc.data() as Map<String, dynamic>);
    }
    return null;
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

  Stream<List<PickupSlotModel>> streamPickupSlots(String marketId) {
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

  Stream<List<NotificationModel>> streamUserNotifications(String userId) {
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

  Future<void> markNotificationAsRead(String notificationId) async {
    await _notificationsRef.doc(notificationId).update({'isRead': true});
  }

  Future<void> markAllNotificationsAsRead(String userId) async {
    QuerySnapshot snap =
        await _notificationsRef.where('userId', isEqualTo: userId).get();
    for (var doc in snap.docs) {
      await doc.reference.update({'isRead': true});
    }
  }

  Stream<List<ReviewModel>> streamReviewsByTarget(String targetId) {
    return _reviewsRef.where('targetId', isEqualTo: targetId).snapshots().map((
      snapshot,
    ) {
      List<ReviewModel> reviews = snapshot.docs
          .map(
            (doc) => ReviewModel.fromMap(
              doc.id,
              doc.data() as Map<String, dynamic>,
            ),
          )
          .toList();
      reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return reviews;
    });
  }

  Stream<List<ReviewModel>> streamFarmerReviews(String farmerId) {
    return _reviewsRef
        .where('targetType', isEqualTo: 'farmer')
        .where('targetId', isEqualTo: farmerId)
        .snapshots()
        .map((snapshot) {
          List<ReviewModel> reviews = snapshot.docs
              .map(
                (doc) => ReviewModel.fromMap(
                  doc.id,
                  doc.data() as Map<String, dynamic>,
                ),
              )
              .toList();
          reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return reviews;
        });
  }

  Stream<List<ReviewModel>> streamProductReviews(String productId) {
    return _reviewsRef
        .where('targetType', isEqualTo: 'product')
        .where('targetId', isEqualTo: productId)
        .snapshots()
        .map((snapshot) {
          List<ReviewModel> reviews = snapshot.docs
              .map(
                (doc) => ReviewModel.fromMap(
                  doc.id,
                  doc.data() as Map<String, dynamic>,
                ),
              )
              .toList();
          reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return reviews;
        });
  }

  Future<void> addReview(ReviewModel review) async {
    DocumentReference ref = _reviewsRef.doc();
    ReviewModel newReview = review.copyWith(id: ref.id);
    await ref.set(newReview.toMap());
  }

  Future<void> deleteReview(String reviewId) async {
    await _reviewsRef.doc(reviewId).delete();
  }

  // --- Audit Logs ---

  Future<void> logAdminAction(AuditLogModel log) async {
    DocumentReference ref = _auditLogsRef.doc();
    AuditLogModel newLog = AuditLogModel(
      id: ref.id,
      actionName: log.actionName,
      performedBy: log.performedBy,
      targetId: log.targetId,
      details: log.details,
      timestamp: log.timestamp,
    );
    await ref.set(newLog.toMap());
  }

  Stream<List<AuditLogModel>> streamAuditLogs() {
    return _auditLogsRef
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) =>
              AuditLogModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  // --- Banners ---
  Stream<List<BannerModel>> streamBanners() {
    return _bannersRef.orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => BannerModel.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList();
    });
  }

  Future<void> addBanner(BannerModel banner) async {
    await _bannersRef.doc(banner.id).set(banner.toMap());
  }

  Future<void> updateBanner(BannerModel banner) async {
    await _bannersRef.doc(banner.id).update(banner.toMap());
  }

  Future<void> deleteBanner(String id) async {
    await _bannersRef.doc(id).delete();
  }

  // --- Offers ---
  Stream<List<OfferModel>> streamOffers() {
    return _offersRef.orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => OfferModel.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList();
    });
  }

  Future<void> addOffer(OfferModel offer) async {
    await _offersRef.doc(offer.id).set(offer.toMap());
  }

  Future<void> updateOffer(OfferModel offer) async {
    await _offersRef.doc(offer.id).update(offer.toMap());
  }

  Future<void> deleteOffer(String id) async {
    await _offersRef.doc(id).delete();
  }

  Future<void> makeOfferLive(OfferModel offer) async {
    await updateOffer(offer.copyWith(isActive: true));
    
    // Broadcast Notification
    await sendNotification(
      userId: offer.targetAudience,
      title: 'New Offer: ${offer.title}',
      message: offer.description,
      type: 'promotion',
    );
  }

  // --- App Config ---
  Stream<AppConfigModel?> streamAppConfig() {
    return _appConfigRef.doc('global').snapshots().map((doc) {
      if (doc.exists) {
        return AppConfigModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    });
  }

  Future<void> updateAppConfig(AppConfigModel config) async {
    await _appConfigRef.doc('global').set(config.toMap(), SetOptions(merge: true));
  }
}
