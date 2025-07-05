import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  @visibleForTesting
  set theme(BusinessTheme? value) {
    _theme = value;
    notifyListeners();
  }

  /// Main method to load theme - checks cache first, then API
  Future<void> loadTheme(String businessId) async {
    debugPrint('[ThemeProvider] loadTheme called for businessId: $businessId');
    
    // First, try to load from cache
    final cachedTheme = await _loadCachedTheme();
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
      await _cacheTheme(theme);
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
        await _cacheTheme(fallback);
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
      await _cacheTheme(theme);
      _hasError = false;
      notifyListeners();
    } catch (e) {
      debugPrint('[ThemeProvider] Background refresh failed: $e');
      // Don't update UI on background refresh failure
    }
  }

  /// Load theme from cache
  Future<BusinessTheme?> _loadCachedTheme() async {
    debugPrint('[ThemeProvider] Checking cache...');
    
    // First check in-memory cache (for development)
    if (_memoryCache != null && _memoryCacheTimestamp != null) {
      debugPrint('[ThemeProvider] 🧠 Found in-memory cache, timestamp: ${DateTime.fromMillisecondsSinceEpoch(_memoryCacheTimestamp!)}');
      return _memoryCache;
    }
    
    // Then check SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('cached_theme');
    final timestamp = prefs.getInt('cached_theme_timestamp');
    
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
        debugPrint('[ThemeProvider] 📦 Found SharedPreferences cache, timestamp: ${DateTime.fromMillisecondsSinceEpoch(timestamp)}');
        
        // Also store in memory cache for faster access
        _memoryCache = theme;
        _memoryCacheTimestamp = timestamp;
        
        return theme;
      } catch (e) {
        debugPrint('[ThemeProvider] Error decoding cached theme: $e');
        await _clearCache();
      }
    } else {
      debugPrint('[ThemeProvider] No cache found - jsonStr: ${jsonStr?.substring(0, jsonStr.length > 50 ? 50 : jsonStr.length)}...');
    }
    return null;
  }

  /// Cache theme with timestamp
  Future<void> _cacheTheme(BusinessTheme theme) async {
    debugPrint('[ThemeProvider] Caching theme...');
    final prefs = await SharedPreferences.getInstance();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final jsonStr = json.encode(theme.toJson());
    
    debugPrint('[ThemeProvider] Cache save debug - JSON length: ${jsonStr.length}');
    debugPrint('[ThemeProvider] Cache save debug - JSON preview: ${jsonStr.substring(0, jsonStr.length > 100 ? 100 : jsonStr.length)}...');
    debugPrint('[ThemeProvider] Cache save debug - Timestamp: $timestamp');
    
    // Save to SharedPreferences
    await prefs.setString('cached_theme', jsonStr);
    await prefs.setInt('cached_theme_timestamp', timestamp);
    
    // Also save to memory cache for development
    _memoryCache = theme;
    _memoryCacheTimestamp = timestamp;
    debugPrint('[ThemeProvider] 🧠 Saved to memory cache');
    
    // Verify the save worked
    final savedJson = prefs.getString('cached_theme');
    final savedTimestamp = prefs.getInt('cached_theme_timestamp');
    debugPrint('[ThemeProvider] Cache save verification - saved JSON exists: ${savedJson != null}');
    debugPrint('[ThemeProvider] Cache save verification - saved timestamp exists: ${savedTimestamp != null}');
    
    debugPrint('[ThemeProvider] Theme cached with timestamp: ${DateTime.fromMillisecondsSinceEpoch(timestamp)}');
  }

  /// Check if cache is expired
  bool _isCacheExpired() {
    // This is a simplified check - in real app you'd check the actual timestamp
    // For now, we'll always consider cache as "fresh" to avoid constant API calls
    return false;
  }

  /// Clear cache
  Future<void> _clearCache() async {
    debugPrint('[ThemeProvider] Clearing cache...');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cached_theme');
    await prefs.remove('cached_theme_timestamp');
  }

  /// Force refresh theme (ignores cache)
  Future<void> refreshTheme(String businessId) async {
    debugPrint('[ThemeProvider] Force refreshing theme...');
    await _clearCache();
    await _loadThemeFromApi(businessId);
  }

  /// Get cached theme without loading from API
  Future<void> loadCachedTheme() async {
    debugPrint('[ThemeProvider] loadCachedTheme called');
    final cachedTheme = await _loadCachedTheme();
    if (cachedTheme != null) {
      _theme = cachedTheme;
      notifyListeners();
    }
  }
} 