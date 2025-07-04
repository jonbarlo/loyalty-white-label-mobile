import 'package:flutter/foundation.dart';
import '../models/punch_card.dart';
import '../services/api_service.dart';

class PunchCardProvider with ChangeNotifier {
  final ApiService _apiService;

  List<PunchCard> _punchCards = [];
  List<PunchCard> _myPunchCards = [];
  bool _isLoading = false;
  String? _error;

  PunchCardProvider(this._apiService);

  List<PunchCard> get punchCards => _punchCards;
  List<PunchCard> get myPunchCards => _myPunchCards;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchPunchCards() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _apiService.getPunchCards();
      _punchCards = data.map((json) => PunchCard.fromJson(json)).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMyPunchCards() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _apiService.getMyPunchCards();
      _myPunchCards = data.map((json) => PunchCard.fromJson(json)).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createPunchCard(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.createPunchCard(data);
      final newPunchCard = PunchCard.fromJson(response);
      _punchCards.add(newPunchCard);
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

  Future<bool> updatePunchCard(int id, Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.updatePunchCard(id, data);
      final updatedPunchCard = PunchCard.fromJson(response);
      
      final index = _punchCards.indexWhere((card) => card.id == id);
      if (index != -1) {
        _punchCards[index] = updatedPunchCard;
      }
      
      final myIndex = _myPunchCards.indexWhere((card) => card.id == id);
      if (myIndex != -1) {
        _myPunchCards[myIndex] = updatedPunchCard;
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

  Future<bool> deletePunchCard(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.deletePunchCard(id);
      _punchCards.removeWhere((card) => card.id == id);
      _myPunchCards.removeWhere((card) => card.id == id);
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

  Future<bool> earnPunch(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.earnPunch(id);
      final updatedPunchCard = PunchCard.fromJson(response);
      
      final index = _punchCards.indexWhere((card) => card.id == id);
      if (index != -1) {
        _punchCards[index] = updatedPunchCard;
      }
      
      final myIndex = _myPunchCards.indexWhere((card) => card.id == id);
      if (myIndex != -1) {
        _myPunchCards[myIndex] = updatedPunchCard;
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

  Future<bool> redeemPunchCard(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.redeemPunchCard(id);
      final updatedPunchCard = PunchCard.fromJson(response);
      
      final index = _punchCards.indexWhere((card) => card.id == id);
      if (index != -1) {
        _punchCards[index] = updatedPunchCard;
      }
      
      final myIndex = _myPunchCards.indexWhere((card) => card.id == id);
      if (myIndex != -1) {
        _myPunchCards[myIndex] = updatedPunchCard;
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

  PunchCard? getPunchCardById(int id) {
    return _punchCards.firstWhere(
      (card) => card.id == id,
      orElse: () => _myPunchCards.firstWhere(
        (card) => card.id == id,
        orElse: () => throw Exception('Punch card not found'),
      ),
    );
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void refresh() {
    fetchPunchCards();
    fetchMyPunchCards();
  }
} 