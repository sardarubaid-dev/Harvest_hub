import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';
import '../models/customer_model.dart';
import '../models/farmer_model.dart';
import '../core/dummy_data.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  String? get currentUserId => _auth.currentUser?.uid;

  static const String adminEmail = "admin@harvesthub.com";
  static const String adminPassword = "AdminPassword123!";

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
        isApproved: true,
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
      if (email.trim().toLowerCase() == adminEmail.toLowerCase() &&
          password == adminPassword) {
        return await _ensureAdminExists();
      }

      // --- DUMMY DATA BYPASS FOR UI TESTING ---
      // Hardcoded passwords for exact dummy data users
      const Map<String, String> validDummyUsers = {
        'ali@example.com': 'customer123',
        'ahmad@example.com': 'farmer123',
        'zain@example.com': 'admin123',
      };

      String normalizedEmail = email.trim().toLowerCase();

      if (validDummyUsers.containsKey(normalizedEmail)) {
        if (validDummyUsers[normalizedEmail] == password) {
          // Find the user from DummyData that matches this exact email
          return DummyData.seedUsers.firstWhere(
            (u) => u.email.toLowerCase() == normalizedEmail,
          );
        } else {
          throw Exception("Invalid password for ${normalizedEmail}.");
        }
      }

      if (password == '123456' || password == 'password123') {
        throw Exception(
          "Please use exact dummy emails (ali@example.com, ahmad@example.com, zain@example.com) and their respective passwords (customer123, farmer123, admin123).",
        );
      }
      // ----------------------------------------

      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      String uid = credential.user!.uid;
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(uid)
          .get();

      if (!userDoc.exists) {
        UserModel fallbackUser = UserModel(
          uid: uid,
          name: credential.user?.displayName ?? 'User',
          email: email.trim(),
          role: 'Customer',
          isActive: true,
        );
        await _firestore.collection('users').doc(uid).set(fallbackUser.toMap());
        return fallbackUser;
      }

      Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
      UserModel user = UserModel.fromMap(uid, data);

      if (!user.isActive) {
        await _auth.signOut();
        throw Exception("Your account has been deactivated by administrator.");
      }

      return user;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel> _ensureAdminExists() async {
    try {
      UserCredential credential;
      try {
        credential = await _auth.signInWithEmailAndPassword(
          email: adminEmail,
          password: adminPassword,
        );
      } catch (_) {
        credential = await _auth.createUserWithEmailAndPassword(
          email: adminEmail,
          password: adminPassword,
        );
      }

      String uid = credential.user!.uid;
      UserModel adminUser = UserModel(
        uid: uid,
        name: "HarvestHub Administrator",
        email: adminEmail,
        role: "Admin",
        isActive: true,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(uid).set(adminUser.toMap());
      return adminUser;
    } catch (e) {
      return UserModel(
        uid: "admin_static_id",
        name: "HarvestHub Administrator",
        email: adminEmail,
        role: "Admin",
        isActive: true,
      );
    }
  }

  Future<UserModel?> getUserModel(String uid) async {
    try {
      // --- DUMMY DATA BYPASS ---
      try {
        var dummy = DummyData.seedUsers.firstWhere((u) => u.uid == uid);
        return dummy;
      } catch (_) {}
      // -------------------------

      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists) {
        return UserModel.fromMap(uid, doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      return null;
    }
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
