import 'package:flutter/foundation.dart';
import '../services/business_image_service.dart';

class BusinessImageProvider with ChangeNotifier {
  final BusinessImageService _businessImageService;
  
  Map<int, String> _businessImages = {};
  Map<int, bool> _loadingStates = {};
  Map<int, String?> _errors = {};

  BusinessImageProvider(this._businessImageService);

  /// Get image URL for a business
  String? getBusinessImage(int businessId) {
    return _businessImages[businessId];
  }

  /// Check if image is loading for a business
  bool isLoading(int businessId) {
    return _loadingStates[businessId] ?? false;
  }

  /// Get error for a business
  String? getError(int businessId) {
    return _errors[businessId];
  }

  /// Load business image
  Future<void> loadBusinessImage(int businessId) async {
    debugPrint('[BusinessImageProvider] loadBusinessImage called for businessId: $businessId');
    
    // Set loading state
    _loadingStates[businessId] = true;
    _errors[businessId] = null;
    notifyListeners();

    try {
      final imageUrl = await _businessImageService.loadBusinessImage(businessId);
      
      if (imageUrl != null) {
        _businessImages[businessId] = imageUrl;
        debugPrint('[BusinessImageProvider] Image loaded for business $businessId: $imageUrl');
      } else {
        debugPrint('[BusinessImageProvider] No image found for business $businessId');
      }
      
      _loadingStates[businessId] = false;
      notifyListeners();
    } catch (e) {
      debugPrint('[BusinessImageProvider] Error loading image for business $businessId: $e');
      _errors[businessId] = e.toString();
      _loadingStates[businessId] = false;
      notifyListeners();
    }
  }

  /// Clear image for a business
  void clearBusinessImage(int businessId) {
    _businessImages.remove(businessId);
    _loadingStates.remove(businessId);
    _errors.remove(businessId);
    notifyListeners();
  }

  /// Clear all images
  void clearAllImages() {
    _businessImages.clear();
    _loadingStates.clear();
    _errors.clear();
    notifyListeners();
  }

  /// Clear cache for a business
  Future<void> clearBusinessCache(int businessId) async {
    await _businessImageService.clearBusinessCache(businessId);
    clearBusinessImage(businessId);
  }

  /// Clear all cache
  Future<void> clearAllCache() async {
    await _businessImageService.clearCache();
    clearAllImages();
  }
} 