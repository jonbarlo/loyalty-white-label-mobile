import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import '../models/business_theme.dart';
import '../services/theme_service.dart';
import 'package:flutter/foundation.dart';

class ThemeProvider with ChangeNotifier {
  final ThemeService _themeService;
  BusinessTheme? _theme;
  bool _isLoading = false;
  bool _hasError = false;
  
  // Cache expiration time (24 hours)
  static const int _cacheExpirationHours = 24;
  
  // In-memory cache for development (persists during same session)
  static BusinessTheme? _memoryCache;
  static int? _memoryCacheTimestamp;

  ThemeProvider(this._themeService);

  BusinessTheme? get theme => _theme;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  
  // Get the dio instance from the theme service
  Dio get dio => _themeService.dio;

  @visibleForTesting
  set theme(BusinessTheme? value) {
    _theme = value;
    notifyListeners();
  }

  /// Main method to load theme - checks cache first, then API
  Future<void> loadTheme(String businessId) async {
    debugPrint('[ThemeProvider] loadTheme called for businessId: $businessId');
    
    // First, try to load from cache
    final cachedTheme = await _loadCachedTheme(businessId);
    if (cachedTheme != null) {
      debugPrint('[ThemeProvider] Using cached theme: ${cachedTheme.toJson()}');
      _theme = cachedTheme;
      _isLoading = false;
      _hasError = false;
      notifyListeners();
      
      // Check if cache is expired and refresh in background
      if (_isCacheExpired()) {
        debugPrint('[ThemeProvider] Cache expired, refreshing in background...');
        _refreshThemeInBackground(businessId);
      }
      return;
    }
    
    // No cache available, load from API
    debugPrint('[ThemeProvider] No cache available, loading from API...');
    await _loadThemeFromApi(businessId);
  }

  /// Load theme from API and cache it
  Future<void> _loadThemeFromApi(String businessId) async {
    _isLoading = true;
    _hasError = false;
    notifyListeners();
    
    try {
      final theme = await _themeService.fetchBusinessTheme(businessId);
      debugPrint('[ThemeProvider] API theme loaded: ${theme.toJson()}');
      _theme = theme;
      await _cacheTheme(theme, businessId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('[ThemeProvider] Error loading theme from API: $e');
      _hasError = true;
      
      // Try fallback theme
      try {
        final fallback = await _themeService.fetchDefaultTheme();
        debugPrint('[ThemeProvider] Using fallback theme: ${fallback.toJson()}');
        _theme = fallback;
        await _cacheTheme(fallback, businessId);
      } catch (e2) {
        debugPrint('[ThemeProvider] Error loading fallback theme: $e2');
        _theme = null;
      }
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh theme in background without blocking UI
  Future<void> _refreshThemeInBackground(String businessId) async {
    try {
      final theme = await _themeService.fetchBusinessTheme(businessId);
      debugPrint('[ThemeProvider] Background refresh successful: ${theme.toJson()}');
      _theme = theme;
      await _cacheTheme(theme, businessId);
      _hasError = false;
      notifyListeners();
    } catch (e) {
      debugPrint('[ThemeProvider] Background refresh failed: $e');
      // Don't update UI on background refresh failure
    }
  }

  /// Load theme from cache
  Future<BusinessTheme?> _loadCachedTheme(String businessId) async {
    debugPrint('[ThemeProvider] Checking cache for businessId: $businessId');
    
    final cacheKey = 'cached_theme_$businessId';
    final timestampKey = 'cached_theme_timestamp_$businessId';
    
    // First check in-memory cache (for development)
    if (_memoryCache != null && _memoryCacheTimestamp != null) {
      debugPrint('[ThemeProvider] 🧠 Found in-memory cache, timestamp: ${DateTime.fromMillisecondsSinceEpoch(_memoryCacheTimestamp!)}');
      return _memoryCache;
    }
    
    // Then check SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(cacheKey);
    final timestamp = prefs.getInt(timestampKey);
    
    debugPrint('[ThemeProvider] Cache debug - jsonStr exists: ${jsonStr != null}');
    debugPrint('[ThemeProvider] Cache debug - timestamp exists: ${timestamp != null}');
    if (timestamp != null) {
      debugPrint('[ThemeProvider] Cache debug - timestamp value: ${DateTime.fromMillisecondsSinceEpoch(timestamp)}');
    }
    
    if (jsonStr != null && timestamp != null) {
      try {
        final jsonMap = json.decode(jsonStr) as Map<String, dynamic>;
        debugPrint('[ThemeProvider] Cache debug - decoded JSON: $jsonMap');
        final theme = BusinessTheme.fromJson(jsonMap);
        debugPrint('[ThemeProvider] 📦 Found SharedPreferences cache for business $businessId, timestamp: ${DateTime.fromMillisecondsSinceEpoch(timestamp)}');
        
        // Also store in memory cache for faster access
        _memoryCache = theme;
        _memoryCacheTimestamp = timestamp;
        
        return theme;
      } catch (e) {
        debugPrint('[ThemeProvider] Error decoding cached theme: $e');
        await _clearCache(businessId);
      }
    } else {
      debugPrint('[ThemeProvider] No cache found for business $businessId - jsonStr: ${jsonStr?.substring(0, jsonStr.length > 50 ? 50 : jsonStr.length)}...');
    }
    return null;
  }

  /// Cache theme with timestamp
  Future<void> _cacheTheme(BusinessTheme theme, String businessId) async {
    debugPrint('[ThemeProvider] Caching theme for business $businessId...');
    final prefs = await SharedPreferences.getInstance();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final jsonStr = json.encode(theme.toJson());
    
    final cacheKey = 'cached_theme_$businessId';
    final timestampKey = 'cached_theme_timestamp_$businessId';
    
    debugPrint('[ThemeProvider] Cache save debug - JSON length: ${jsonStr.length}');
    debugPrint('[ThemeProvider] Cache save debug - JSON preview: ${jsonStr.substring(0, jsonStr.length > 100 ? 100 : jsonStr.length)}...');
    debugPrint('[ThemeProvider] Cache save debug - Timestamp: $timestamp');
    debugPrint('[ThemeProvider] Cache save debug - Cache key: $cacheKey');
    
    // Save to SharedPreferences
    await prefs.setString(cacheKey, jsonStr);
    await prefs.setInt(timestampKey, timestamp);
    
    // Also save to memory cache for development
    _memoryCache = theme;
    _memoryCacheTimestamp = timestamp;
    debugPrint('[ThemeProvider] 🧠 Saved to memory cache');
    
    // Verify the save worked
    final savedJson = prefs.getString(cacheKey);
    final savedTimestamp = prefs.getInt(timestampKey);
    debugPrint('[ThemeProvider] Cache save verification - saved JSON exists: ${savedJson != null}');
    debugPrint('[ThemeProvider] Cache save verification - saved timestamp exists: ${savedTimestamp != null}');
    
    debugPrint('[ThemeProvider] Theme cached for business $businessId with timestamp: ${DateTime.fromMillisecondsSinceEpoch(timestamp)}');
  }

  /// Check if cache is expired
  bool _isCacheExpired() {
    // This is a simplified check - in real app you'd check the actual timestamp
    // For now, we'll always consider cache as "fresh" to avoid constant API calls
    return false;
  }

  /// Clear cache
  Future<void> _clearCache(String businessId) async {
    debugPrint('[ThemeProvider] Clearing cache for business $businessId...');
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'cached_theme_$businessId';
    final timestampKey = 'cached_theme_timestamp_$businessId';
    await prefs.remove(cacheKey);
    await prefs.remove(timestampKey);
  }

  /// Force refresh theme (ignores cache)
  Future<void> refreshTheme(String businessId) async {
    debugPrint('[ThemeProvider] Force refreshing theme for business $businessId...');
    await _clearCache(businessId);
    await _loadThemeFromApi(businessId);
  }

  /// Get cached theme without loading from API
  Future<void> loadCachedTheme(String businessId) async {
    debugPrint('[ThemeProvider] loadCachedTheme called for business $businessId');
    final cachedTheme = await _loadCachedTheme(businessId);
    if (cachedTheme != null) {
      _theme = cachedTheme;
      notifyListeners();
    }
  }

  /// Set theme directly (used after saving)
  void setTheme(BusinessTheme theme) {
    debugPrint('[ThemeProvider] setTheme called with: ${theme.toJson()}');
    _theme = theme;
    // Note: setTheme doesn't have businessId context, so we can't cache it properly
    // The theme will be cached when loadTheme is called next time
    notifyListeners();
  }

  /// Clear all theme cache (useful for debugging)
  Future<void> clearAllCache() async {
    debugPrint('[ThemeProvider] Clearing all theme cache...');
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    
    for (final key in keys) {
      if (key.startsWith('cached_theme_')) {
        await prefs.remove(key);
        debugPrint('[ThemeProvider] Removed cache key: $key');
      }
    }
    
    // Clear in-memory cache
    _memoryCache = null;
    _memoryCacheTimestamp = null;
    debugPrint('[ThemeProvider] 🗑️ Cleared all theme cache');
  }
} 