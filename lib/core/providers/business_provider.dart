import 'package:flutter/foundation.dart';
import '../models/business.dart';
import '../services/api_service.dart';

class BusinessProvider with ChangeNotifier {
  final ApiService _apiService;

  List<Business> _businesses = [];
  Business? _selectedBusiness;
  bool _isLoading = false;
  String? _error;

  BusinessProvider(this._apiService);

  List<Business> get businesses => _businesses;
  Business? get selectedBusiness => _selectedBusiness;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get active businesses only
  List<Business> get activeBusinesses => _businesses.where((b) => b.isActive).toList();

  Future<void> loadBusinesses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _apiService.getBusinesses();
      _businesses = data.map((json) => Business.fromJson(json)).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadBusiness(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _apiService.getBusiness(id);
      _selectedBusiness = Business.fromJson(data);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createBusiness(Map<String, dynamic> businessData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _apiService.createBusiness(businessData);
      final newBusiness = Business.fromJson(data);
      _businesses.add(newBusiness);
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

  Future<bool> updateBusiness(int id, Map<String, dynamic> businessData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _apiService.updateBusiness(id, businessData);
      final updatedBusiness = Business.fromJson(data);
      
      final index = _businesses.indexWhere((b) => b.id == id);
      if (index != -1) {
        _businesses[index] = updatedBusiness;
      }
      
      if (_selectedBusiness?.id == id) {
        _selectedBusiness = updatedBusiness;
      }
      
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

  Future<bool> deleteBusiness(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.deleteBusiness(id);
      _businesses.removeWhere((b) => b.id == id);
      
      if (_selectedBusiness?.id == id) {
        _selectedBusiness = null;
      }
      
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

  void selectBusiness(Business? business) {
    _selectedBusiness = business;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Business? getBusinessById(int id) {
    try {
      return _businesses.firstWhere((b) => b.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Business> searchBusinesses(String query) {
    if (query.isEmpty) return _businesses;
    
    return _businesses.where((business) {
      return business.name.toLowerCase().contains(query.toLowerCase()) ||
             (business.description?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
             (business.address?.toLowerCase().contains(query.toLowerCase()) ?? false);
    }).toList();
  }
} 