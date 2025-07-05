import 'package:dio/dio.dart';
import '../models/business_theme.dart';
import 'package:flutter/foundation.dart';

class ThemeService {
  final Dio dio;
  ThemeService(this.dio);

  Future<BusinessTheme> fetchBusinessTheme(String businessId) async {
    final url = '/businesses/$businessId/theme';
    try {
      debugPrint('[ThemeService] 🌐 Making API call to: $url');
      final response = await dio.get(url);
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
      final response = await dio.get(url);
      debugPrint('[ThemeService] ✅ API Response: ${response.data}');
      
      final theme = BusinessTheme.fromJson(response.data);
      debugPrint('[ThemeService] 🎨 Parsed default theme - backgroundColor: ${theme.backgroundColor}');
      
      return theme;
    } catch (e) {
      debugPrint('[ThemeService] ❌ Error fetching $url: $e');
      throw Exception('Failed to fetch default theme: $e');
    }
  }

  Future<BusinessTheme> updateBusinessTheme(String businessId, BusinessTheme theme) async {
    final url = '/businesses/$businessId/theme';
    try {
      debugPrint('[ThemeService] 🌐 Making PUT API call to: $url');
      debugPrint('[ThemeService] 📤 Sending theme data: ${theme.toJson()}');
      
      final response = await dio.put(url, data: theme.toJson());
      debugPrint('[ThemeService] ✅ API Response: ${response.data}');
      
      final updatedTheme = BusinessTheme.fromJson(response.data);
      debugPrint('[ThemeService] 🎨 Updated theme - backgroundColor: ${updatedTheme.backgroundColor}');
      
      return updatedTheme;
    } catch (e) {
      debugPrint('[ThemeService] ❌ Error updating theme at $url: $e');
      throw Exception('Failed to update business theme: $e');
    }
  }
} 