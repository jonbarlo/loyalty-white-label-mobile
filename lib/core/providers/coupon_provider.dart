import 'package:flutter/foundation.dart';
import '../models/coupon.dart';
import '../services/coupon_service.dart';

class CouponProvider with ChangeNotifier {
  final CouponService _couponService;

  CouponProvider(this._couponService);

  // State variables
  List<Coupon> _businessCoupons = [];
  List<Coupon> _myCoupons = [];
  List<Coupon> _couponHistory = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Coupon> get businessCoupons => _businessCoupons;
  List<Coupon> get myCoupons => _myCoupons;
  List<Coupon> get couponHistory => _couponHistory;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Business Owner Methods

  /// Load all coupons for the business
  Future<void> loadBusinessCoupons() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('[CouponProvider] Loading business coupons...');
      _businessCoupons = await _couponService.getBusinessCoupons();
      debugPrint('[CouponProvider] Loaded ${_businessCoupons.length} business coupons');
    } catch (e) {
      debugPrint('[CouponProvider] Error loading business coupons: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a new coupon
  Future<bool> createCoupon(Map<String, dynamic> couponData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('[CouponProvider] Creating coupon...');
      final newCoupon = await _couponService.createCoupon(couponData);
      _businessCoupons.add(newCoupon);
      debugPrint('[CouponProvider] Coupon created successfully: ${newCoupon.title}');
      return true;
    } catch (e) {
      debugPrint('[CouponProvider] Error creating coupon: $e');
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update an existing coupon
  Future<bool> updateCoupon(int couponId, Map<String, dynamic> couponData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('[CouponProvider] Updating coupon $couponId...');
      final updatedCoupon = await _couponService.updateCoupon(couponId, couponData);
      final index = _businessCoupons.indexWhere((c) => c.id == couponId);
      if (index != -1) {
        _businessCoupons[index] = updatedCoupon;
      }
      debugPrint('[CouponProvider] Coupon updated successfully: ${updatedCoupon.title}');
      return true;
    } catch (e) {
      debugPrint('[CouponProvider] Error updating coupon: $e');
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete a coupon
  Future<bool> deleteCoupon(int couponId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('[CouponProvider] Deleting coupon $couponId...');
      await _couponService.deleteCoupon(couponId);
      _businessCoupons.removeWhere((c) => c.id == couponId);
      debugPrint('[CouponProvider] Coupon deleted successfully');
      return true;
    } catch (e) {
      debugPrint('[CouponProvider] Error deleting coupon: $e');
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Toggle coupon active status
  Future<bool> toggleCouponStatus(int couponId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('[CouponProvider] Toggling coupon status $couponId...');
      final updatedCoupon = await _couponService.toggleCouponStatus(couponId);
      final index = _businessCoupons.indexWhere((c) => c.id == couponId);
      if (index != -1) {
        _businessCoupons[index] = updatedCoupon;
      }
      debugPrint('[CouponProvider] Coupon status toggled successfully');
      return true;
    } catch (e) {
      debugPrint('[CouponProvider] Error toggling coupon status: $e');
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Distribute coupon to customers
  Future<bool> distributeCoupon(int couponId, List<int> customerIds) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('[CouponProvider] Distributing coupon $couponId to ${customerIds.length} customers...');
      await _couponService.distributeCoupon(couponId, customerIds);
      debugPrint('[CouponProvider] Coupon distributed successfully');
      return true;
    } catch (e) {
      debugPrint('[CouponProvider] Error distributing coupon: $e');
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get coupon statistics
  Future<Map<String, dynamic>?> getCouponStatistics(int couponId) async {
    try {
      debugPrint('[CouponProvider] Getting statistics for coupon $couponId...');
      return await _couponService.getCouponStatistics(couponId);
    } catch (e) {
      debugPrint('[CouponProvider] Error getting coupon statistics: $e');
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Customer Methods

  /// Load customer's available coupons
  Future<void> loadMyCoupons() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('[CouponProvider] Loading my coupons...');
      _myCoupons = await _couponService.getMyCoupons();
      debugPrint('[CouponProvider] Loaded ${_myCoupons.length} coupons');
    } catch (e) {
      debugPrint('[CouponProvider] Error loading my coupons: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load customer's coupon history
  Future<void> loadCouponHistory() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('[CouponProvider] Loading coupon history...');
      _couponHistory = await _couponService.getMyCouponHistory();
      debugPrint('[CouponProvider] Loaded ${_couponHistory.length} historical coupons');
    } catch (e) {
      debugPrint('[CouponProvider] Error loading coupon history: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Redeem a coupon
  Future<Map<String, dynamic>?> redeemCoupon(int couponId, double purchaseAmount) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('[CouponProvider] Redeeming coupon $couponId for amount $purchaseAmount...');
      final result = await _couponService.redeemCoupon(couponId, purchaseAmount);
      
      // Remove the redeemed coupon from my coupons
      _myCoupons.removeWhere((c) => c.id == couponId);
      
      debugPrint('[CouponProvider] Coupon redeemed successfully');
      return result;
    } catch (e) {
      debugPrint('[CouponProvider] Error redeeming coupon: $e');
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Utility methods

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Get coupon by ID from business coupons
  Coupon? getBusinessCouponById(int id) {
    try {
      return _businessCoupons.firstWhere((coupon) => coupon.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get coupon by ID from my coupons
  Coupon? getMyCouponById(int id) {
    try {
      return _myCoupons.firstWhere((coupon) => coupon.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get available coupons (active and not expired)
  List<Coupon> get availableCoupons {
    return _myCoupons.where((coupon) => coupon.isAvailable).toList();
  }

  /// Get expired coupons
  List<Coupon> get expiredCoupons {
    return _myCoupons.where((coupon) => coupon.isExpired).toList();
  }
} 