import 'package:flutter/foundation.dart';
import '../models/point_transaction.dart';
import '../services/api_service.dart';

class PointTransactionProvider with ChangeNotifier {
  final ApiService _apiService;

  List<PointTransaction> _pointTransactions = [];
  List<PointTransaction> _myPointTransactions = [];
  bool _isLoading = false;
  String? _error;

  PointTransactionProvider(this._apiService);

  List<PointTransaction> get pointTransactions => _pointTransactions;
  List<PointTransaction> get myPointTransactions => _myPointTransactions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchPointTransactions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _apiService.getPointTransactions();
      _pointTransactions = data.map((json) => PointTransaction.fromJson(json)).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMyPointTransactions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _apiService.getMyPointTransactions();
      _myPointTransactions = data.map((json) => PointTransaction.fromJson(json)).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createPointTransaction(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.createPointTransaction(data);
      final newTransaction = PointTransaction.fromJson(response);
      _pointTransactions.add(newTransaction);
      _myPointTransactions.add(newTransaction);
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

  PointTransaction? getPointTransactionById(int id) {
    try {
      return _pointTransactions.firstWhere(
        (transaction) => transaction.id == id,
        orElse: () => _myPointTransactions.firstWhere(
          (transaction) => transaction.id == id,
          orElse: () => throw Exception('Point transaction not found'),
        ),
      );
    } catch (e) {
      return null;
    }
  }

  List<PointTransaction> getTransactionsByType(String type) {
    return _myPointTransactions.where((transaction) => transaction.type == type).toList();
  }

  int getTotalPoints() {
    return _myPointTransactions.fold(0, (total, transaction) {
      if (transaction.type == 'earn') {
        return total + transaction.points;
      } else if (transaction.type == 'redeem') {
        return total - transaction.points;
      }
      return total;
    });
  }

  List<PointTransaction> getRecentTransactions({int limit = 10}) {
    final sorted = List<PointTransaction>.from(_myPointTransactions);
    sorted.sort((a, b) => b.id.compareTo(a.id));
    return sorted.take(limit).toList();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void refresh() {
    fetchPointTransactions();
    fetchMyPointTransactions();
  }
} 