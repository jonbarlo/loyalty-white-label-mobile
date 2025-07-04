import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService;
  final StorageService _storageService;

  User? _user;
  bool _isLoading = false;
  String? _error;

  AuthProvider(this._apiService, this._storageService) {
    _initializeAuth();
  }

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  Future<void> _initializeAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = _storageService.getAuthToken();
      if (token != null) {
        final userData = await _apiService.getCurrentUser();
        _user = User.fromJson(userData);
      }
    } catch (e) {
      // Token might be invalid, clear it
      await _storageService.removeAuthToken();
      await _storageService.removeUserData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.login(email, password);
      
      final token = response['token'];
      final userData = response['user'];
      
      await _storageService.saveAuthToken(token);
      await _storageService.saveUserData(userData);
      
      _user = User.fromJson(userData);
      _isLoading = false;
      notifyListeners();
      
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.register(name, email, password);
      
      final token = response['token'];
      final userData = response['user'];
      
      await _storageService.saveAuthToken(token);
      await _storageService.saveUserData(userData);
      
      _user = User.fromJson(userData);
      _isLoading = false;
      notifyListeners();
      
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _storageService.clearAllData();
      _user = null;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshUser() async {
    if (_user == null) return;

    try {
      final userData = await _apiService.getCurrentUser();
      _user = User.fromJson(userData);
      await _storageService.saveUserData(userData);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  bool get isAdmin => _user?.role == 'admin';
  bool get isBusinessOwner => _user?.role == 'business_owner';
  bool get isCustomer => _user?.role == 'customer';
} 