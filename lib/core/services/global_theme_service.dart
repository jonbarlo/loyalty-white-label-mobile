import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../models/business_theme.dart';

/// Global theme service that can be called from anywhere in the app
class GlobalThemeService {
  static final GlobalThemeService _instance = GlobalThemeService._internal();
  factory GlobalThemeService() => _instance;
  GlobalThemeService._internal();

  /// Get the current theme from the provider
  static BusinessTheme? getCurrentTheme(BuildContext context) {
    try {
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      return themeProvider.theme;
    } catch (e) {
      debugPrint('[GlobalThemeService] ❌ Error getting theme: $e');
      return null;
    }
  }

  /// Get the background color for a specific page
  static Color? getBackgroundColor(BuildContext context, {String? pageName}) {
    final theme = getCurrentTheme(context);
    if (theme != null) {
      debugPrint('[GlobalThemeService] 🎨 Getting background color for $pageName: ${theme.backgroundColor}');
      return theme.backgroundColor;
    }
    debugPrint('[GlobalThemeService] ⚠️ No theme available for $pageName');
    return null;
  }

  /// Get the primary color
  static Color? getPrimaryColor(BuildContext context) {
    final theme = getCurrentTheme(context);
    return theme?.primaryColor;
  }

  /// Get the secondary color
  static Color? getSecondaryColor(BuildContext context) {
    final theme = getCurrentTheme(context);
    return theme?.secondaryColor;
  }

  /// Get the surface color (for cards, containers)
  static Color? getSurfaceColor(BuildContext context) {
    final theme = getCurrentTheme(context);
    return theme?.surfaceColor;
  }

  /// Get the text primary color
  static Color? getTextPrimaryColor(BuildContext context) {
    final theme = getCurrentTheme(context);
    return theme?.textPrimaryColor;
  }

  /// Get the text secondary color
  static Color? getTextSecondaryColor(BuildContext context) {
    final theme = getCurrentTheme(context);
    return theme?.textSecondaryColor;
  }

  /// Get the button primary color
  static Color? getButtonPrimaryColor(BuildContext context) {
    final theme = getCurrentTheme(context);
    return theme?.buttonPrimaryColor ?? theme?.primaryColor;
  }

  /// Get the button secondary color
  static Color? getButtonSecondaryColor(BuildContext context) {
    final theme = getCurrentTheme(context);
    return theme?.buttonSecondaryColor ?? theme?.secondaryColor;
  }

  /// Get the app bar color
  static Color? getAppBarColor(BuildContext context) {
    final theme = getCurrentTheme(context);
    return theme?.appBarColor ?? theme?.surfaceColor;
  }

  /// Get the error color
  static Color? getErrorColor(BuildContext context) {
    final theme = getCurrentTheme(context);
    return theme?.errorColor;
  }

  /// Get the divider color
  static Color? getDividerColor(BuildContext context) {
    final theme = getCurrentTheme(context);
    return theme?.dividerColor;
  }

  /// Get the border radius
  static double? getBorderRadius(BuildContext context) {
    final theme = getCurrentTheme(context);
    return theme?.borderRadius;
  }

  /// Get the elevation
  static double? getElevation(BuildContext context) {
    final theme = getCurrentTheme(context);
    return theme?.elevation;
  }

  /// Get the font family
  static String? getFontFamily(BuildContext context) {
    final theme = getCurrentTheme(context);
    return theme?.fontFamily;
  }

  /// Get the body font size
  static double? getFontSizeBody(BuildContext context) {
    final theme = getCurrentTheme(context);
    return theme?.fontSizeBody;
  }

  /// Get the heading font size
  static double? getFontSizeHeading(BuildContext context) {
    final theme = getCurrentTheme(context);
    return theme?.fontSizeHeading;
  }

  /// Get the caption font size
  static double? getFontSizeCaption(BuildContext context) {
    final theme = getCurrentTheme(context);
    return theme?.fontSizeCaption;
  }

  /// Get the default margin
  static double? getDefaultMargin(BuildContext context) {
    final theme = getCurrentTheme(context);
    return theme?.defaultMargin;
  }

  /// Get the default padding
  static double? getDefaultPadding(BuildContext context) {
    final theme = getCurrentTheme(context);
    return theme?.defaultPadding;
  }

  /// Get the button height
  static double? getButtonHeight(BuildContext context) {
    final theme = getCurrentTheme(context);
    return theme?.buttonHeight;
  }

  /// Get the app bar height
  static double? getAppBarHeight(BuildContext context) {
    final theme = getCurrentTheme(context);
    return theme?.appBarHeight;
  }

  /// Get the icon size
  static double? getIconSize(BuildContext context) {
    final theme = getCurrentTheme(context);
    return theme?.iconSize;
  }

  /// Check if theme is loading
  static bool isLoading(BuildContext context) {
    try {
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      return themeProvider.isLoading;
    } catch (e) {
      return false;
    }
  }

  /// Check if theme has error
  static bool hasError(BuildContext context) {
    try {
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      return themeProvider.hasError;
    } catch (e) {
      return false;
    }
  }

  /// Force refresh theme
  static Future<void> refreshTheme(BuildContext context, String businessId) async {
    try {
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      await themeProvider.refreshTheme(businessId);
      debugPrint('[GlobalThemeService] 🔄 Theme refreshed for business: $businessId');
    } catch (e) {
      debugPrint('[GlobalThemeService] ❌ Error refreshing theme: $e');
    }
  }

  /// Load theme for a business
  static Future<void> loadTheme(BuildContext context, String businessId) async {
    try {
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      await themeProvider.loadTheme(businessId);
      debugPrint('[GlobalThemeService] 📥 Theme loaded for business: $businessId');
    } catch (e) {
      debugPrint('[GlobalThemeService] ❌ Error loading theme: $e');
    }
  }

  /// Get debug info about current theme
  static void printDebugInfo(BuildContext context) {
    final theme = getCurrentTheme(context);
    if (theme != null) {
      debugPrint('[GlobalThemeService] 📊 Current Theme Debug Info:');
      debugPrint('  - backgroundColor: ${theme.backgroundColor}');
      debugPrint('  - primaryColor: ${theme.primaryColor}');
      debugPrint('  - secondaryColor: ${theme.secondaryColor}');
      debugPrint('  - fontFamily: ${theme.fontFamily}');
      debugPrint('  - isLoading: ${isLoading(context)}');
      debugPrint('  - hasError: ${hasError(context)}');
    } else {
      debugPrint('[GlobalThemeService] 📊 No theme available');
    }
  }
} 