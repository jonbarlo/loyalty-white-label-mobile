import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:loyalty_mobile_app/core/models/business_theme.dart';
import 'package:loyalty_mobile_app/core/providers/theme_provider.dart';
import 'package:loyalty_mobile_app/core/theme/app_theme.dart';
import 'package:loyalty_mobile_app/core/services/theme_service.dart';

class FakeThemeService implements ThemeService {
  @override
  Future<BusinessTheme> fetchBusinessTheme(String businessId) {
    throw UnimplementedError();
  }
  @override
  Future<BusinessTheme> fetchDefaultTheme() {
    throw UnimplementedError();
  }
}

void main() {
  testWidgets('MaterialApp uses dynamic theme from ThemeProvider', (WidgetTester tester) async {
    final theme = BusinessTheme(
      primaryColor: const Color(0xFF4F46E5),
      secondaryColor: const Color(0xFF6366F1),
      backgroundColor: const Color(0xFFFFFFFF),
      fontFamily: 'RobotoFlex',
      fontSizeBody: 16,
      fontSizeHeading: 24,
      borderRadius: 12,
      elevation: 4,
    );
    final provider = ThemeProvider(FakeThemeService());
    provider.theme = theme;
    await tester.pumpWidget(
      ChangeNotifierProvider<ThemeProvider>.value(
        value: provider,
        child: Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return MaterialApp(
              theme: AppTheme.businessThemeToThemeData(themeProvider.theme ?? theme),
              home: const Scaffold(body: Text('Test')), // Use a test widget
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.theme?.primaryColor, theme.primaryColor);
  });
} 