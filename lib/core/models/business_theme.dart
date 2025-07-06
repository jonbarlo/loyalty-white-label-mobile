import 'package:flutter/material.dart';

class BusinessTheme {
  final Color primaryColor;
  final Color secondaryColor;
  final Color backgroundColor;
  final String fontFamily;
  final double fontSizeBody;
  final double fontSizeHeading;
  final double borderRadius;
  final double elevation;
  final Color? surfaceColor;
  final Color? errorColor;
  final Color? onPrimaryColor;
  final Color? onSecondaryColor;
  final Color? dividerColor;
  final Color? textPrimaryColor;
  final Color? textSecondaryColor;
  final double? fontSizeCaption;
  final double? defaultMargin;
  final Color? buttonPrimaryColor;
  final Color? buttonSecondaryColor;
  final double? defaultPadding;
  final double? buttonHeight;
  final Color? appBarColor;
  final double? appBarHeight;
  final double? iconSize;

  BusinessTheme({
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
    required this.fontFamily,
    required this.fontSizeBody,
    required this.fontSizeHeading,
    required this.borderRadius,
    required this.elevation,
    this.surfaceColor,
    this.errorColor,
    this.onPrimaryColor,
    this.onSecondaryColor,
    this.dividerColor,
    this.textPrimaryColor,
    this.textSecondaryColor,
    this.fontSizeCaption,
    this.defaultMargin,
    this.buttonPrimaryColor,
    this.buttonSecondaryColor,
    this.defaultPadding,
    this.buttonHeight,
    this.appBarColor,
    this.appBarHeight,
    this.iconSize,
  });

  factory BusinessTheme.fromJson(Map<String, dynamic> json) {
    return BusinessTheme(
      primaryColor: _parseColor(json['primaryColor']),
      secondaryColor: _parseColor(json['secondaryColor']),
      backgroundColor: _parseColor(json['backgroundColor']),
      fontFamily: json['fontFamily'] ?? 'RobotoFlex',
      fontSizeBody: (json['fontSizeBody'] as num?)?.toDouble() ?? 16.0,
      fontSizeHeading: (json['fontSizeHeading'] as num?)?.toDouble() ?? 24.0,
      borderRadius: (json['borderRadius'] as num?)?.toDouble() ?? 12.0,
      elevation: (json['elevation'] as num?)?.toDouble() ?? 4.0,
      surfaceColor: json['surfaceColor'] != null ? _parseColor(json['surfaceColor']) : null,
      errorColor: json['errorColor'] != null ? _parseColor(json['errorColor']) : null,
      onPrimaryColor: json['onPrimaryColor'] != null ? _parseColor(json['onPrimaryColor']) : null,
      onSecondaryColor: json['onSecondaryColor'] != null ? _parseColor(json['onSecondaryColor']) : null,
      dividerColor: json['dividerColor'] != null ? _parseColor(json['dividerColor']) : null,
      textPrimaryColor: json['textPrimaryColor'] != null ? _parseColor(json['textPrimaryColor']) : null,
      textSecondaryColor: json['textSecondaryColor'] != null ? _parseColor(json['textSecondaryColor']) : null,
      fontSizeCaption: (json['fontSizeCaption'] as num?)?.toDouble(),
      defaultMargin: (json['defaultMargin'] as num?)?.toDouble(),
      buttonPrimaryColor: json['buttonPrimaryColor'] != null ? _parseColor(json['buttonPrimaryColor']) : null,
      buttonSecondaryColor: json['buttonSecondaryColor'] != null ? _parseColor(json['buttonSecondaryColor']) : null,
      defaultPadding: (json['defaultPadding'] as num?)?.toDouble(),
      buttonHeight: (json['buttonHeight'] as num?)?.toDouble(),
      appBarColor: json['appBarColor'] != null ? _parseColor(json['appBarColor']) : null,
      appBarHeight: (json['appBarHeight'] as num?)?.toDouble(),
      iconSize: (json['iconSize'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'primaryColor': _colorToHex(primaryColor),
      'secondaryColor': _colorToHex(secondaryColor),
      'backgroundColor': _colorToHex(backgroundColor),
      'fontFamily': fontFamily,
      'fontSizeBody': fontSizeBody,
      'fontSizeHeading': fontSizeHeading,
      'borderRadius': borderRadius,
      'elevation': elevation,
      'surfaceColor': surfaceColor != null ? _colorToHex(surfaceColor!) : null,
      'errorColor': errorColor != null ? _colorToHex(errorColor!) : null,
      'onPrimaryColor': onPrimaryColor != null ? _colorToHex(onPrimaryColor!) : null,
      'onSecondaryColor': onSecondaryColor != null ? _colorToHex(onSecondaryColor!) : null,
      'dividerColor': dividerColor != null ? _colorToHex(dividerColor!) : null,
      'textPrimaryColor': textPrimaryColor != null ? _colorToHex(textPrimaryColor!) : null,
      'textSecondaryColor': textSecondaryColor != null ? _colorToHex(textSecondaryColor!) : null,
      'fontSizeCaption': fontSizeCaption,
      'defaultMargin': defaultMargin,
      'buttonPrimaryColor': buttonPrimaryColor != null ? _colorToHex(buttonPrimaryColor!) : null,
      'buttonSecondaryColor': buttonSecondaryColor != null ? _colorToHex(buttonSecondaryColor!) : null,
      'defaultPadding': defaultPadding,
      'buttonHeight': buttonHeight,
      'appBarColor': appBarColor != null ? _colorToHex(appBarColor!) : null,
      'appBarHeight': appBarHeight,
      'iconSize': iconSize,
    };
  }

  static Color _parseColor(dynamic value) {
    if (value == null) {
      // Return a default color if value is null
      return const Color(0xFF000000);
    }
    if (value is int) return Color(value);
    if (value is String && value.startsWith('#')) {
      final hex = value.replaceFirst('#', '');
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      } else if (hex.length == 8) {
        return Color(int.parse(hex, radix: 16));
      }
    }
    // Return a default color instead of throwing an error
    debugPrint('Warning: Invalid color value: $value, using default black');
    return const Color(0xFF000000);
  }

  static String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }
} 