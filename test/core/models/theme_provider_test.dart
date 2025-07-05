import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:loyalty_mobile_app/core/models/business_theme.dart';
import 'package:loyalty_mobile_app/core/services/theme_service.dart';
import 'package:loyalty_mobile_app/core/providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'theme_provider_test.mocks.dart';

@GenerateMocks([ThemeService])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ThemeProvider', () {
    late MockThemeService mockThemeService;
    late ThemeProvider themeProvider;
    late BusinessTheme businessTheme;
    late BusinessTheme defaultTheme;

    setUp(() {
      mockThemeService = MockThemeService();
      businessTheme = BusinessTheme(
        primaryColor: const Color(0xFF4F46E5),
        secondaryColor: const Color(0xFF6366F1),
        backgroundColor: const Color(0xFFFFFFFF),
        fontFamily: 'RobotoFlex',
        fontSizeBody: 16,
        fontSizeHeading: 24,
        borderRadius: 12,
        elevation: 4,
      );
      defaultTheme = BusinessTheme(
        primaryColor: const Color(0xFF23232A),
        secondaryColor: const Color(0xFF6366F1),
        backgroundColor: const Color(0xFFFFFFFF),
        fontFamily: 'RobotoFlex',
        fontSizeBody: 16,
        fontSizeHeading: 24,
        borderRadius: 12,
        elevation: 4,
      );
      SharedPreferences.setMockInitialValues({});
      themeProvider = ThemeProvider(mockThemeService);
    });

    test('loads business theme successfully', () async {
      when(mockThemeService.fetchBusinessTheme('1')).thenAnswer((_) async => businessTheme);
      await themeProvider.loadTheme('1');
      expect(themeProvider.theme, businessTheme);
      expect(themeProvider.isLoading, false);
      expect(themeProvider.hasError, false);
    });

    test('falls back to default theme on error', () async {
      when(mockThemeService.fetchBusinessTheme('2')).thenThrow(Exception('error'));
      when(mockThemeService.fetchDefaultTheme()).thenAnswer((_) async => defaultTheme);
      await themeProvider.loadTheme('2');
      expect(themeProvider.theme, defaultTheme);
      expect(themeProvider.hasError, true);
    });

    test('caches and loads theme from SharedPreferences', () async {
      when(mockThemeService.fetchBusinessTheme('1')).thenAnswer((_) async => businessTheme);
      await themeProvider.loadTheme('1');
      // Create a new provider to simulate app restart
      final newProvider = ThemeProvider(mockThemeService);
      await newProvider.loadCachedTheme();
      expect(newProvider.theme?.primaryColor, businessTheme.primaryColor);
    });

    test('switches business and loads new theme', () async {
      when(mockThemeService.fetchBusinessTheme('1')).thenAnswer((_) async => businessTheme);
      when(mockThemeService.fetchBusinessTheme('2')).thenAnswer((_) async => defaultTheme);
      await themeProvider.loadTheme('1');
      expect(themeProvider.theme, businessTheme);
      await themeProvider.loadTheme('2');
      expect(themeProvider.theme, defaultTheme);
    });
  });
} 