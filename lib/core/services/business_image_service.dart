import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

class BusinessImageService {
  final Dio _dio;
  
  // Cache expiration time (24 hours)
  static const int _cacheExpirationHours = 24;
  
  // In-memory cache for development (persists during same session)
  static Map<String, String> _memoryCache = {};
  static Map<String, int> _memoryCacheTimestamp = {};

  BusinessImageService(this._dio);

  /// Load business image with caching - checks cache first, then API
  Future<String?> loadBusinessImage(int businessId) async {
    debugPrint('[BusinessImageService] loadBusinessImage called for businessId: $businessId');
    
    final cacheKey = 'business_image_$businessId';
    
    // First, try to load from cache
    final cachedImage = await _loadCachedImage(cacheKey);
    if (cachedImage != null) {
      debugPrint('[BusinessImageService] Using cached image for business $businessId');
      return cachedImage;
    }
    
    // No cache available, load from API
    debugPrint('[BusinessImageService] No cache available, loading from API...');
    return await _loadImageFromApi(businessId, cacheKey);
  }

  /// Load image from API and cache it
  Future<String?> _loadImageFromApi(int businessId, String cacheKey) async {
    try {
      final response = await _dio.get('/public/businesses/$businessId');
      final businessData = response.data;
      final imageUrl = businessData['logoUrl'];
      
      if (imageUrl != null && imageUrl.isNotEmpty) {
        debugPrint('[BusinessImageService] API image loaded: $imageUrl');
        await _cacheImage(cacheKey, imageUrl);
        return imageUrl;
      } else {
        debugPrint('[BusinessImageService] No image URL found for business $businessId');
        return null;
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        debugPrint('[BusinessImageService] 401 Unauthorized - business image requires authentication');
        // For now, we'll use a default image or return null
        // In a real app, you might want to:
        // 1. Use a public endpoint for business logos
        // 2. Load the image after user authentication
        // 3. Use a default logo for the business
        return null;
      } else {
        debugPrint('[BusinessImageService] Error loading image from API: $e');
        return null;
      }
    } catch (e) {
      debugPrint('[BusinessImageService] Unexpected error loading image from API: $e');
      return null;
    }
  }

  /// Load image from cache
  Future<String?> _loadCachedImage(String cacheKey) async {
    try {
      // Check in-memory cache first (for development)
      if (_memoryCache.containsKey(cacheKey)) {
        final timestamp = _memoryCacheTimestamp[cacheKey];
        if (timestamp != null && !_isCacheExpired(timestamp)) {
          debugPrint('[BusinessImageService] Using in-memory cache for $cacheKey');
          return _memoryCache[cacheKey];
        } else {
          // Clear expired in-memory cache
          _memoryCache.remove(cacheKey);
          _memoryCacheTimestamp.remove(cacheKey);
        }
      }

      // Check SharedPreferences cache
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(cacheKey);
      
      if (cachedData != null) {
        final data = json.decode(cachedData);
        final imageUrl = data['imageUrl'] as String;
        final timestamp = data['timestamp'] as int;
        
        if (!_isCacheExpired(timestamp)) {
          debugPrint('[BusinessImageService] Using SharedPreferences cache for $cacheKey');
          // Also update in-memory cache
          _memoryCache[cacheKey] = imageUrl;
          _memoryCacheTimestamp[cacheKey] = timestamp;
          return imageUrl;
        } else {
          debugPrint('[BusinessImageService] Cache expired for $cacheKey');
          await prefs.remove(cacheKey);
        }
      }
      
      return null;
    } catch (e) {
      debugPrint('[BusinessImageService] Error loading cached image: $e');
      return null;
    }
  }

  /// Cache image data
  Future<void> _cacheImage(String cacheKey, String imageUrl) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final data = {
        'imageUrl': imageUrl,
        'timestamp': timestamp,
      };
      
      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(cacheKey, json.encode(data));
      debugPrint('[BusinessImageService] Saved to SharedPreferences cache: $cacheKey');
      
      // Also save to in-memory cache
      _memoryCache[cacheKey] = imageUrl;
      _memoryCacheTimestamp[cacheKey] = timestamp;
      debugPrint('[BusinessImageService] Saved to in-memory cache: $cacheKey');
    } catch (e) {
      debugPrint('[BusinessImageService] Error caching image: $e');
    }
  }

  /// Check if cache is expired
  bool _isCacheExpired(int timestamp) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final expirationTime = _cacheExpirationHours * 60 * 60 * 1000; // Convert hours to milliseconds
    return (now - timestamp) > expirationTime;
  }

  /// Clear all cached images
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      for (final key in keys) {
        if (key.startsWith('business_image_')) {
          await prefs.remove(key);
        }
      }
      
      // Clear in-memory cache
      _memoryCache.clear();
      _memoryCacheTimestamp.clear();
      
      debugPrint('[BusinessImageService] All image cache cleared');
    } catch (e) {
      debugPrint('[BusinessImageService] Error clearing cache: $e');
    }
  }

  /// Clear cache for specific business
  Future<void> clearBusinessCache(int businessId) async {
    try {
      final cacheKey = 'business_image_$businessId';
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(cacheKey);
      
      // Clear from in-memory cache
      _memoryCache.remove(cacheKey);
      _memoryCacheTimestamp.remove(cacheKey);
      
      debugPrint('[BusinessImageService] Cache cleared for business $businessId');
    } catch (e) {
      debugPrint('[BusinessImageService] Error clearing business cache: $e');
    }
  }
} 