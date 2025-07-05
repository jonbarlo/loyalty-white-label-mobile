import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';
import 'package:loyalty_mobile_app/core/models/business_theme.dart';
import 'package:loyalty_mobile_app/core/services/theme_service.dart';

import 'theme_service_test.mocks.dart';

@GenerateMocks([Dio])
void main() {
  group('ThemeService', () {
    late MockDio mockDio;
    late ThemeService themeService;

    setUp(() {
      mockDio = MockDio();
      themeService = ThemeService(mockDio);
    });

    test('fetchBusinessTheme returns BusinessTheme on success', () async {
      final responseData = {
        'primaryColor': '#4F46E5',
        'secondaryColor': '#6366F1',
        'backgroundColor': '#FFFFFF',
        'fontFamily': 'RobotoFlex',
        'fontSizeBody': 16,
        'fontSizeHeading': 24,
        'borderRadius': 12,
        'elevation': 4,
      };
      when(mockDio.get('/api/businesses/1/theme')).thenAnswer((_) async => Response(
        data: responseData,
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      ));
      final theme = await themeService.fetchBusinessTheme('1');
      expect(theme.primaryColor, const Color(0xFF4F46E5));
      expect(theme.fontFamily, 'RobotoFlex');
    });

    test('fetchDefaultTheme returns BusinessTheme on success', () async {
      final responseData = {
        'primaryColor': '#23232A',
        'secondaryColor': '#6366F1',
        'backgroundColor': '#FFFFFF',
        'fontFamily': 'RobotoFlex',
        'fontSizeBody': 16,
        'fontSizeHeading': 24,
        'borderRadius': 12,
        'elevation': 4,
      };
      when(mockDio.get('/api/themes/default')).thenAnswer((_) async => Response(
        data: responseData,
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      ));
      final theme = await themeService.fetchDefaultTheme();
      expect(theme.primaryColor, const Color(0xFF23232A));
    });

    test('fetchBusinessTheme throws on error', () async {
      when(mockDio.get('/api/businesses/2/theme')).thenThrow(DioError(
        requestOptions: RequestOptions(path: ''),
        error: 'Not found',
        response: Response(statusCode: 404, requestOptions: RequestOptions(path: '')),
        type: DioErrorType.badResponse,
      ));
      expect(() => themeService.fetchBusinessTheme('2'), throwsA(isA<Exception>()));
    });
  });
} 