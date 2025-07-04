import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static const String _defaultAppName = 'Loyalty Mobile App';
  static const String _defaultApiUrl = 'http://localhost:3000';
  static const int _defaultApiTimeout = 30000;
  static const String _defaultAppVersion = '1.0.0';

  // App Configuration
  static String get appName => dotenv.env['APP_NAME'] ?? _defaultAppName;
  static String get appVersion => dotenv.env['APP_VERSION'] ?? _defaultAppVersion;
  
  // API Configuration
  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? _defaultApiUrl;
  static int get apiTimeout => int.tryParse(dotenv.env['API_TIMEOUT'] ?? '$_defaultApiTimeout') ?? _defaultApiTimeout;
  
  // Feature Flags
  static bool get enableNotifications => dotenv.env['ENABLE_NOTIFICATIONS']?.toLowerCase() == 'true';
  static bool get enableQrCode => dotenv.env['ENABLE_QR_CODE']?.toLowerCase() == 'true';
  
  // Development
  static bool get debugMode => dotenv.env['DEBUG_MODE']?.toLowerCase() == 'true';

  // Initialize environment variables
  static Future<void> initialize() async {
    try {
      await dotenv.load(fileName: 'env.example');
    } catch (e) {
      // If .env file doesn't exist, use default values
      print('Warning: Environment file not found, using default values');
    }
  }

  // Get all configuration as a map (useful for debugging)
  static Map<String, dynamic> getAllConfig() {
    return {
      'appName': appName,
      'appVersion': appVersion,
      'apiBaseUrl': apiBaseUrl,
      'apiTimeout': apiTimeout,
      'enableNotifications': enableNotifications,
      'enableQrCode': enableQrCode,
      'debugMode': debugMode,
    };
  }
} 