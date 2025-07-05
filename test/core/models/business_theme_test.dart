import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loyalty_mobile_app/core/models/business_theme.dart';

void main() {
  group('BusinessTheme', () {
    test('fromJson parses valid JSON', () {
      final json = {
        'primaryColor': '#4F46E5',
        'secondaryColor': '#6366F1',
        'backgroundColor': '#FFFFFF',
        'fontFamily': 'RobotoFlex',
        'fontSizeBody': 16,
        'fontSizeHeading': 24,
        'borderRadius': 12,
        'elevation': 4,
      };
      final theme = BusinessTheme.fromJson(json);
      expect(theme.primaryColor, const Color(0xFF4F46E5));
      expect(theme.secondaryColor, const Color(0xFF6366F1));
      expect(theme.backgroundColor, const Color(0xFFFFFFFF));
      expect(theme.fontFamily, 'RobotoFlex');
      expect(theme.fontSizeBody, 16);
      expect(theme.fontSizeHeading, 24);
      expect(theme.borderRadius, 12);
      expect(theme.elevation, 4);
    });

    test('toJson outputs correct map', () {
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
      final json = theme.toJson();
      expect(json['primaryColor'], '#FF4F46E5');
      expect(json['secondaryColor'], '#FF6366F1');
      expect(json['backgroundColor'], '#FFFFFFFF');
      expect(json['fontFamily'], 'RobotoFlex');
      expect(json['fontSizeBody'], 16);
      expect(json['fontSizeHeading'], 24);
      expect(json['borderRadius'], 12);
      expect(json['elevation'], 4);
    });

    test('fromJson throws on invalid color', () {
      final json = {
        'primaryColor': 'notacolor',
        'secondaryColor': '#6366F1',
        'backgroundColor': '#FFFFFF',
        'fontFamily': 'RobotoFlex',
        'fontSizeBody': 16,
        'fontSizeHeading': 24,
        'borderRadius': 12,
        'elevation': 4,
      };
      expect(() => BusinessTheme.fromJson(json), throwsArgumentError);
    });

    test('fromJson supports int color', () {
      final json = {
        'primaryColor': 0xFF4F46E5,
        'secondaryColor': 0xFF6366F1,
        'backgroundColor': 0xFFFFFFFF,
        'fontFamily': 'RobotoFlex',
        'fontSizeBody': 16,
        'fontSizeHeading': 24,
        'borderRadius': 12,
        'elevation': 4,
      };
      final theme = BusinessTheme.fromJson(json);
      expect(theme.primaryColor, const Color(0xFF4F46E5));
      expect(theme.secondaryColor, const Color(0xFF6366F1));
      expect(theme.backgroundColor, const Color(0xFFFFFFFF));
    });
  });
} 