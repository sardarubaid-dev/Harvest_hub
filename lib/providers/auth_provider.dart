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

  bool _isLoading = true;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  FarmerModel? get currentFarmer => _currentFarmer;
  CustomerModel? get currentCustomer => _currentCustomer;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get isAuthenticated => _currentUser != null;
  bool get isCustomer => _currentUser?.isCustomer ?? false;
  bool get isFarmer => _currentUser?.isFarmer ?? false;
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  AuthProvider() {
    _init();
  }

  void _init() {
    _authService.authStateChanges.listen((firebaseUser) async {
      if (firebaseUser == null) {
        _currentUser = null;
        _currentFarmer = null;
        _currentCustomer = null;
        _isLoading = false;
        notifyListeners();
      } else {
        await fetchUserData(firebaseUser.uid);
      }
    });
  }

  Future<void> fetchUserData(String uid) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _authService.getUserModel(uid);
      if (_currentUser != null) {
        if (_currentUser!.isFarmer) {
          _currentFarmer = await _databaseService.getFarmerByUserId(uid);
        } else if (_currentUser!.isCustomer) {
          _databaseService.streamCustomer(uid).listen((customer) {
            _currentCustomer = customer;
            notifyListeners();
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
      _currentUser = await _authService.login(email: email, password: password);
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
