import 'package:flutter/foundation.dart';
import '../models/notification.dart';
import '../services/api_service.dart';

class NotificationProvider with ChangeNotifier {
  final ApiService _apiService;

  List<NotificationModel> _notifications = [];
  List<NotificationModel> _myNotifications = [];
  bool _isLoading = false;
  String? _error;

  NotificationProvider(this._apiService);

  List<NotificationModel> get notifications => _notifications;
  List<NotificationModel> get myNotifications => _myNotifications;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<NotificationModel> get unreadNotifications => 
      _myNotifications.where((notification) => !notification.isRead).toList();

  int get unreadCount => unreadNotifications.length;

  Future<void> fetchNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _apiService.getNotifications();
      _notifications = data.map((json) => NotificationModel.fromJson(json)).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMyNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _apiService.getMyNotifications();
      _myNotifications = data.map((json) => NotificationModel.fromJson(json)).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> markAsRead(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.markNotificationAsRead(id);
      final updatedNotification = NotificationModel.fromJson(response);
      
      final index = _notifications.indexWhere((notification) => notification.id == id);
      if (index != -1) {
        _notifications[index] = updatedNotification;
      }
      
      final myIndex = _myNotifications.indexWhere((notification) => notification.id == id);
      if (myIndex != -1) {
        _myNotifications[myIndex] = updatedNotification;
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> markAllAsRead() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      for (final notification in unreadNotifications) {
        await _apiService.markNotificationAsRead(notification.id);
      }
      
      // Update local state
      _notifications = _notifications.map((notification) => 
          notification.copyWith(isRead: true)).toList();
      _myNotifications = _myNotifications.map((notification) => 
          notification.copyWith(isRead: true)).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  NotificationModel? getNotificationById(int id) {
    try {
      return _notifications.firstWhere(
        (notification) => notification.id == id,
        orElse: () => _myNotifications.firstWhere(
          (notification) => notification.id == id,
          orElse: () => throw Exception('Notification not found'),
        ),
      );
    } catch (e) {
      return null;
    }
  }

  List<NotificationModel> getNotificationsByType(String type) {
    return _myNotifications.where((notification) => notification.type == type).toList();
  }

  List<NotificationModel> getRecentNotifications({int limit = 10}) {
    final sorted = List<NotificationModel>.from(_myNotifications);
    sorted.sort((a, b) => b.id.compareTo(a.id));
    return sorted.take(limit).toList();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void refresh() {
    fetchNotifications();
    fetchMyNotifications();
  }
} 