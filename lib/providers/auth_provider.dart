import 'dart:async';
import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import '../models/farmer_model.dart';
import '../models/customer_model.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();

  UserModel? _currentUser;
  FarmerModel? _currentFarmer;
  CustomerModel? _currentCustomer;
  StreamSubscription<CustomerModel?>? _customerSub;

  bool _isLoading = true;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  FarmerModel? get currentFarmer => _currentFarmer;
  CustomerModel? get currentCustomer => _currentCustomer;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get isAuthenticated =>
      _currentUser != null || _authService.currentUserId != null;
  bool get isCustomer => _currentUser?.isCustomer ?? true;
  bool get isFarmer => _currentUser?.isFarmer ?? false;
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  AuthProvider() {
    _init();
  }

  void _init() {
    _authService.authStateChanges.listen((firebaseUser) async {
      if (firebaseUser == null) {
        await _customerSub?.cancel();
        _customerSub = null;
        _currentUser = null;
        _currentFarmer = null;
        _currentCustomer = null;
        _isLoading = false;
        notifyListeners();
      } else {
        if (_currentUser == null || _currentUser!.uid != firebaseUser.uid) {
          await fetchUserData(firebaseUser.uid);
        }
      }
    });
  }

  Future<void> fetchUserData(String uid) async {
    try {
      final fetched = await _authService.getUserModel(uid);
      if (fetched != null) {
        _currentUser = fetched;
      }
      if (_currentUser != null) {
        if (_currentUser!.isFarmer) {
          _currentFarmer = await _databaseService.getFarmerByUserId(uid);
        } else if (_currentUser!.isCustomer) {
          await _customerSub?.cancel();
          _customerSub = _databaseService.streamCustomer(uid).listen((customer) {
            _currentCustomer = customer;
          });
        }
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final loggedInUser = await _authService.login(
        email: email,
        password: password,
      );
      if (loggedInUser != null) {
        _currentUser = loggedInUser;
        await fetchUserData(loggedInUser.uid);
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = _cleanExceptionMessage(e.toString());
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signUpCustomer({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String address,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authService.signUpCustomer(
        email: email,
        password: password,
        name: name,
        phone: phone,
        address: address,
      );
      if (_currentUser != null) {
        await fetchUserData(_currentUser!.uid);
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = _cleanExceptionMessage(e.toString());
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signUpFarmer({
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
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authService.signUpFarmer(
        email: email,
        password: password,
        name: name,
        farmName: farmName,
        description: description,
        location: location,
        contactNumber: contactNumber,
        marketId: marketId,
        latitude: latitude,
        longitude: longitude,
        profileImageUrl: profileImageUrl,
      );
      if (_currentUser != null) {
        await fetchUserData(_currentUser!.uid);
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = _cleanExceptionMessage(e.toString());
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    await _authService.signOut();
    _currentUser = null;
    _currentFarmer = null;
    _currentCustomer = null;
    _isLoading = false;
    notifyListeners();
  }

  String _cleanExceptionMessage(String msg) {
    if (msg.contains("] ")) {
      return msg.split("] ").last;
    }
    return msg.replaceAll("Exception: ", "");
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
