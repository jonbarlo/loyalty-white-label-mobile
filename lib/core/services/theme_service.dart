import 'package:dio/dio.dart';
import '../models/business_theme.dart';
import 'package:flutter/foundation.dart';

class ThemeService {
  final Dio _dio;
  ThemeService(this._dio);

  Future<BusinessTheme> fetchBusinessTheme(String businessId) async {
    final url = '/businesses/$businessId/theme';
    try {
      debugPrint('[ThemeService] 🌐 Making API call to: $url');
      final response = await _dio.get(url);
      debugPrint('[ThemeService] ✅ API Response: ${response.data}');
      
      final theme = BusinessTheme.fromJson(response.data);
      debugPrint('[ThemeService] 🎨 Parsed theme - backgroundColor: ${theme.backgroundColor}');
      
      return theme;
    } catch (e) {
      debugPrint('[ThemeService] ❌ Error fetching $url: $e');
      throw Exception('Failed to fetch business theme: $e');
    }
  }

  Future<BusinessTheme> fetchDefaultTheme() async {
    final url = '/themes/default';
    try {
      debugPrint('[ThemeService] 🌐 Making API call to: $url');
      final response = await _dio.get(url);
      debugPrint('[ThemeService] ✅ API Response: ${response.data}');
      
      final theme = BusinessTheme.fromJson(response.data);
      debugPrint('[ThemeService] 🎨 Parsed default theme - backgroundColor: ${theme.backgroundColor}');
      
      return theme;
    } catch (e) {
      debugPrint('[ThemeService] ❌ Error fetching $url: $e');
      throw Exception('Failed to fetch default theme: $e');
    }
  }
} 