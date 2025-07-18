import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/business.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  late Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: Duration(milliseconds: AppConfig.apiTimeout),
      receiveTimeout: Duration(milliseconds: AppConfig.apiTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add auth token if available
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        // Handle common errors
        if (error.response?.statusCode == 401) {
          // Token expired or invalid
          _handleUnauthorized();
        }
        handler.next(error);
      },
    ));
  }

  void _handleUnauthorized() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
    // You might want to navigate to login screen here
  }

  // Auth endpoints
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      debugPrint('[ApiService] POST \\${_dio.options.baseUrl}/auth/login');
      debugPrint('[ApiService] Login data: email=$email, password=${password.substring(0, 3)}***');
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      debugPrint('[ApiService] Login response: ${response.data}');
      return response.data;
    } on DioException catch (e) {
      debugPrint('[ApiService] Login error: ${e.message}');
      debugPrint('[ApiService] Login error response: ${e.response?.data}');
      debugPrint('[ApiService] Login error status: ${e.response?.statusCode}');
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> register(String name, String email, String password, [String? businessId]) async {
    try {
      final data = {
        'name': name,
        'email': email,
        'password': password,
      };
      
      // Only include businessId if it's provided and not empty
      if (businessId != null && businessId.isNotEmpty) {
        data['businessId'] = businessId;
      }
      
      final response = await _dio.post('/auth/register', data: data);
      debugPrint('[ApiService] POST \\${_dio.options.baseUrl}/auth/register');
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await _dio.get('/users/me');
      debugPrint('[ApiService] GET \\${_dio.options.baseUrl}/users/me');
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Punch Card endpoints
  Future<List<Map<String, dynamic>>> getPunchCards() async {
    try {
      final response = await _dio.get('/punch-cards');
      debugPrint('[ApiService] GET \\${_dio.options.baseUrl}/punch-cards');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> getMyPunchCards() async {
    try {
      final response = await _dio.get('/my-punch-cards');
      debugPrint('[ApiService] GET \\${_dio.options.baseUrl}/my-punch-cards');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> createPunchCard(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/punch-cards', data: data);
      debugPrint('[ApiService] POST \\${_dio.options.baseUrl}/punch-cards');
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> getPunchCard(int id) async {
    try {
      final response = await _dio.get('/punch-cards/$id');
      debugPrint('[ApiService] GET \\${_dio.options.baseUrl}/punch-cards/$id');
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> updatePunchCard(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/punch-cards/$id', data: data);
      debugPrint('[ApiService] PUT \\${_dio.options.baseUrl}/punch-cards/$id');
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> deletePunchCard(int id) async {
    try {
      await _dio.delete('/punch-cards/$id');
      debugPrint('[ApiService] DELETE \\${_dio.options.baseUrl}/punch-cards/$id');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> earnPunch(int id) async {
    try {
      final response = await _dio.post('/punch-cards/$id/earn');
      debugPrint('[ApiService] POST \\${_dio.options.baseUrl}/punch-cards/$id/earn');
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> redeemPunchCard(int id) async {
    try {
      final response = await _dio.post('/punch-cards/$id/redeem');
      debugPrint('[ApiService] POST \\${_dio.options.baseUrl}/punch-cards/$id/redeem');
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Point Transaction endpoints
  Future<List<Map<String, dynamic>>> getPointTransactions() async {
    try {
      final response = await _dio.get('/point-transactions');
      debugPrint('[ApiService] GET \\${_dio.options.baseUrl}/point-transactions');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> getMyPointTransactions() async {
    try {
      final response = await _dio.get('/my-point-transactions');
      debugPrint('[ApiService] GET \\${_dio.options.baseUrl}/my-point-transactions');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> createPointTransaction(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/point-transactions', data: data);
      debugPrint('[ApiService] POST \\${_dio.options.baseUrl}/point-transactions');
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Reward endpoints
  Future<List<Map<String, dynamic>>> getRewards() async {
    try {
      final response = await _dio.get('/rewards');
      debugPrint('[ApiService] GET \\${_dio.options.baseUrl}/rewards');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> createReward(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/rewards', data: data);
      debugPrint('[ApiService] POST \\${_dio.options.baseUrl}/rewards');
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Reward Program endpoints
  Future<List<Map<String, dynamic>>> getRewardPrograms() async {
    try {
      final response = await _dio.get('/reward-programs');
      debugPrint('[ApiService] GET \\${_dio.options.baseUrl}/reward-programs');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> createRewardProgram(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/reward-programs', data: data);
      debugPrint('[ApiService] POST \\${_dio.options.baseUrl}/reward-programs');
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Notification endpoints
  Future<List<Map<String, dynamic>>> getNotifications() async {
    try {
      final response = await _dio.get('/notifications');
      debugPrint('[ApiService] GET \\${_dio.options.baseUrl}/notifications');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> getMyNotifications() async {
    try {
      final response = await _dio.get('/my-notifications');
      debugPrint('[ApiService] GET \\${_dio.options.baseUrl}/my-notifications');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> markNotificationAsRead(int id) async {
    try {
      final response = await _dio.patch('/notifications/$id/read');
      debugPrint('[ApiService] PATCH \\${_dio.options.baseUrl}/notifications/$id/read');
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Business endpoints
  Future<List<Map<String, dynamic>>> getBusinesses() async {
    try {
      final response = await _dio.get('/businesses');
      debugPrint('[ApiService] GET \\${_dio.options.baseUrl}/businesses');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> getBusiness(int id) async {
    try {
      final response = await _dio.get('/businesses/$id');
      debugPrint('[ApiService] GET \\${_dio.options.baseUrl}/businesses/$id');
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> createBusiness(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/businesses', data: data);
      debugPrint('[ApiService] POST \\${_dio.options.baseUrl}/businesses');
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> updateBusiness(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/businesses/$id', data: data);
      debugPrint('[ApiService] PUT \\${_dio.options.baseUrl}/businesses/$id');
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> deleteBusiness(int id) async {
    try {
      await _dio.delete('/businesses/$id');
      debugPrint('[ApiService] DELETE \\${_dio.options.baseUrl}/businesses/$id');
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
        
        // Try to extract error message from different possible formats
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

  Dio get dio => _dio;
} 