import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';
import '../models/customer_model.dart';
import '../models/farmer_model.dart';

class AuthService {
  static const String adminEmail = 'admin@harvesthub.com';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  String? get currentUserId => _auth.currentUser?.uid;

  static String get adminPassword => 'admin123';

  Future<UserModel> signUpCustomer({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String address,
  }) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      String uid = credential.user!.uid;

      UserModel newUser = UserModel(
        uid: uid,
        name: name.trim(),
        email: email.trim(),
        role: 'Customer',
        phone: phone.trim(),
        address: address.trim(),
        isActive: true,
        createdAt: DateTime.now(),
      );

      CustomerModel customer = CustomerModel(
        id: uid,
        userId: uid,
        name: name.trim(),
        email: email.trim(),
        phone: phone.trim(),
        address: address.trim(),
        wishlist: [],
        followedFarmers: [],
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(uid).set(newUser.toMap());
      await _firestore.collection('customers').doc(uid).set(customer.toMap());

      return newUser;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel> signUpFarmer({
    required String email,
    required String password,
    required String name,
    required String farmName,
    required String description,
    required String location,
    required String contactNumber,
    String? marketId,
    double? latitude,
    double? longitude,
    String? profileImageUrl,
    List<String>? verificationDocs,
  }) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      String uid = credential.user!.uid;

      UserModel newUser = UserModel(
        uid: uid,
        name: name.trim(),
        email: email.trim(),
        role: 'Farmer',
        phone: contactNumber.trim(),
        address: location.trim(),
        isActive: true,
        createdAt: DateTime.now(),
      );

      DocumentReference farmerRef = _firestore.collection('farmers').doc();
      FarmerModel farmer = FarmerModel(
        id: farmerRef.id,
        userId: uid,
        farmName: farmName.trim(),
        description: description.trim(),
        location: location.trim(),
        contactNumber: contactNumber.trim(),
        marketId: marketId,
        rating: 5.0,
        isApproved: false,
        latitude: latitude,
        longitude: longitude,
        profileImageUrl: profileImageUrl,
        verificationDocs: verificationDocs ?? [],
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(uid).set(newUser.toMap());
      await farmerRef.set(farmer.toMap());

      return newUser;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel?> login({
    required String email,
    required String password,
  }) async {
    try {

      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      String uid = credential.user!.uid;
      try {
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(uid)
            .get();

        if (!userDoc.exists) {
          UserModel fallbackUser = UserModel(
            uid: uid,
            name: credential.user?.displayName?.trim().isNotEmpty == true
                ? credential.user!.displayName!
                : email.split('@').first,
            email: email.trim(),
            role: email.trim().toLowerCase() == adminEmail.toLowerCase() ? 'Admin' : 'Customer',
            isActive: true,
          );
          try {
            await _firestore
                .collection('users')
                .doc(uid)
                .set(fallbackUser.toMap());
          } catch (_) {}
          return fallbackUser;
        }

        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        UserModel user = UserModel.fromMap(uid, data);

        if (!user.isActive) {
          await _auth.signOut();
          throw Exception(
            "Your account has been deactivated by administrator.",
          );
        }

        return user;
      } catch (innerError) {
        if (innerError.toString().contains('deactivated')) {
          rethrow;
        }
        return UserModel(
          uid: uid,
          name: credential.user?.displayName?.trim().isNotEmpty == true
              ? credential.user!.displayName!
              : email.split('@').first,
          email: email.trim(),
          role: 'Customer',
          isActive: true,
        );
      }
    } catch (e) {
      rethrow;
    }
  }


  Future<UserModel?> getUserModel(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(uid, doc.data() as Map<String, dynamic>);
      }
    } catch (_) {}

    final fbUser = _auth.currentUser;
    if (fbUser != null && fbUser.uid == uid) {
      final email = fbUser.email ?? '';
      return UserModel(
        uid: uid,
        name: fbUser.displayName?.trim().isNotEmpty == true
            ? fbUser.displayName!
            : (email.isNotEmpty ? email.split('@').first : 'Customer'),
        email: email,
        role: email.toLowerCase() == AuthService.adminEmail.toLowerCase()
            ? 'Admin'
            : 'Customer',
        isActive: true,
      );
    }
    return null;
  }

  Future<UserModel?> getCurrentUserModel() async {
    User? user = _auth.currentUser;
    if (user == null) return null;
    return await getUserModel(user.uid);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }
}
