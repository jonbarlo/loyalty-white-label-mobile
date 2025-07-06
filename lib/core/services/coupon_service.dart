import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/coupon.dart';
import 'api_service.dart';

class CouponService {
  final ApiService _apiService;

  CouponService(this._apiService);

  // Business Owner Endpoints

  /// Get all coupons for a business
  Future<List<Coupon>> getBusinessCoupons() async {
    try {
      debugPrint('[CouponService] GET \\${_apiService.dio.options.baseUrl}/coupons');
      final response = await _apiService.dio.get('/coupons');
      final List<dynamic> data = response.data;
      return data.map((json) => Coupon.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Create a new coupon
  Future<Coupon> createCoupon(Map<String, dynamic> couponData) async {
    try {
      debugPrint('[CouponService] POST \\${_apiService.dio.options.baseUrl}/coupons');
      final response = await _apiService.dio.post('/coupons', data: couponData);
      return Coupon.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get coupon details by ID
  Future<Coupon> getCoupon(int couponId) async {
    try {
      debugPrint('[CouponService] GET \\${_apiService.dio.options.baseUrl}/coupons/$couponId');
      final response = await _apiService.dio.get('/coupons/$couponId');
      return Coupon.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Update coupon
  Future<Coupon> updateCoupon(int couponId, Map<String, dynamic> couponData) async {
    try {
      debugPrint('[CouponService] PUT \\${_apiService.dio.options.baseUrl}/coupons/$couponId');
      final response = await _apiService.dio.put('/coupons/$couponId', data: couponData);
      return Coupon.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Delete coupon
  Future<void> deleteCoupon(int couponId) async {
    try {
      debugPrint('[CouponService] DELETE \\${_apiService.dio.options.baseUrl}/coupons/$couponId');
      await _apiService.dio.delete('/coupons/$couponId');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Toggle coupon active status
  Future<Coupon> toggleCouponStatus(int couponId) async {
    try {
      debugPrint('[CouponService] PATCH \\${_apiService.dio.options.baseUrl}/coupons/$couponId/toggle');
      final response = await _apiService.dio.patch('/coupons/$couponId/toggle');
      return Coupon.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Distribute coupon to customers
  Future<Map<String, dynamic>> distributeCoupon(int couponId, List<int> customerIds) async {
    try {
      debugPrint('[CouponService] POST \\${_apiService.dio.options.baseUrl}/coupons/$couponId/distribute');
      final response = await _apiService.dio.post(
        '/coupons/$couponId/distribute',
        data: {'customerIds': customerIds},
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get coupon statistics
  Future<Map<String, dynamic>> getCouponStatistics(int couponId) async {
    try {
      debugPrint('[CouponService] GET \\${_apiService.dio.options.baseUrl}/coupons/$couponId/stats');
      final response = await _apiService.dio.get('/coupons/$couponId/stats');
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Customer Endpoints

  /// Get customer's available coupons
  Future<List<Coupon>> getMyCoupons() async {
    try {
      debugPrint('[CouponService] GET \\${_apiService.dio.options.baseUrl}/coupons');
      final response = await _apiService.dio.get('/coupons');
      final List<dynamic> data = response.data;
      // Filter to only show active and available coupons for customers
      final coupons = data.map((json) => Coupon.fromJson(json)).toList();
      return coupons.where((coupon) => 
        coupon.isActive && 
        !coupon.isExpired && 
        coupon.usedQuantity < coupon.totalQuantity
      ).toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get customer's coupon history (redeemed and expired)
  Future<List<Coupon>> getMyCouponHistory() async {
    try {
      debugPrint('[CouponService] GET \\${_apiService.dio.options.baseUrl}/coupons');
      final response = await _apiService.dio.get('/coupons');
      final List<dynamic> data = response.data;
      // Filter to show expired or fully used coupons for history
      final coupons = data.map((json) => Coupon.fromJson(json)).toList();
      return coupons.where((coupon) => 
        coupon.isExpired || 
        coupon.usedQuantity >= coupon.totalQuantity ||
        !coupon.isActive
      ).toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Redeem a coupon
  Future<Map<String, dynamic>> redeemCoupon(int couponId, double purchaseAmount) async {
    try {
      debugPrint('[CouponService] POST \\${_apiService.dio.options.baseUrl}/coupons/$couponId/redeem');
      final response = await _apiService.dio.post(
        '/coupons/$couponId/redeem',
        data: {'purchaseAmount': purchaseAmount},
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Connection timeout. Please check your internet connection.');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final responseData = error.response?.data;
        String message = 'An error occurred';
        
        if (responseData is Map<String, dynamic>) {
          message = responseData['error'] ?? 
                   responseData['message'] ?? 
                   responseData['detail'] ?? 
                   'An error occurred';
        } else if (responseData is String) {
          message = responseData;
        }
        
        return Exception('Error $statusCode: $message');
      case DioExceptionType.cancel:
        return Exception('Request was cancelled');
      default:
        return Exception('Network error occurred. Please try again.');
    }
  }
} 