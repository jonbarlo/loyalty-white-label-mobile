import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

/// Test service to verify SharedPreferences functionality
class StorageTestService {
  static const String _testKey = 'theme_cache_test';
  static const String _testTimestampKey = 'theme_cache_test_timestamp';

  /// Test if SharedPreferences is working
  static Future<void> testSharedPreferences() async {
    debugPrint('[StorageTest] 🧪 Testing SharedPreferences...');
    
    final prefs = await SharedPreferences.getInstance();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final testData = 'Test theme data at $timestamp';
    
    // Save test data
    await prefs.setString(_testKey, testData);
    await prefs.setInt(_testTimestampKey, timestamp);
    
    debugPrint('[StorageTest] ✅ Saved test data: $testData');
    debugPrint('[StorageTest] ✅ Saved timestamp: ${DateTime.fromMillisecondsSinceEpoch(timestamp)}');
    
    // Verify save worked
    final savedData = prefs.getString(_testKey);
    final savedTimestamp = prefs.getInt(_testTimestampKey);
    
    debugPrint('[StorageTest] 🔍 Verification - saved data exists: ${savedData != null}');
    debugPrint('[StorageTest] 🔍 Verification - saved timestamp exists: ${savedTimestamp != null}');
    
    if (savedData != null && savedTimestamp != null) {
      debugPrint('[StorageTest] ✅ SharedPreferences is working correctly!');
      debugPrint('[StorageTest] 📊 Test data: $savedData');
      debugPrint('[StorageTest] 📊 Test timestamp: ${DateTime.fromMillisecondsSinceEpoch(savedTimestamp)}');
    } else {
      debugPrint('[StorageTest] ❌ SharedPreferences test failed!');
    }
  }

  /// Check if test data exists (for restart testing)
  static Future<void> checkTestData() async {
    debugPrint('[StorageTest] 🔍 Checking for existing test data...');
    
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString(_testKey);
    final savedTimestamp = prefs.getInt(_testTimestampKey);
    
    if (savedData != null && savedTimestamp != null) {
      debugPrint('[StorageTest] ✅ Found existing test data!');
      debugPrint('[StorageTest] 📊 Data: $savedData');
      debugPrint('[StorageTest] 📊 Timestamp: ${DateTime.fromMillisecondsSinceEpoch(savedTimestamp)}');
    } else {
      debugPrint('[StorageTest] ❌ No existing test data found');
      debugPrint('[StorageTest] 💡 This is normal in Chrome development mode');
    }
  }

  /// Clear test data
  static Future<void> clearTestData() async {
    debugPrint('[StorageTest] 🗑️ Clearing test data...');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_testKey);
    await prefs.remove(_testTimestampKey);
    debugPrint('[StorageTest] ✅ Test data cleared');
  }

  /// Get all SharedPreferences keys for debugging
  static Future<void> listAllKeys() async {
    debugPrint('[StorageTest] 📋 Listing all SharedPreferences keys...');
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    
    if (keys.isEmpty) {
      debugPrint('[StorageTest] 📋 No keys found in SharedPreferences');
    } else {
      debugPrint('[StorageTest] 📋 Found ${keys.length} keys:');
      for (final key in keys) {
        final value = prefs.get(key);
        debugPrint('[StorageTest]   - $key: $value');
      }
    }
  }
} 