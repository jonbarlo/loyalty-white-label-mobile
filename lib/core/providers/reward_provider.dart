import 'package:flutter/foundation.dart';
import '../models/reward.dart';
import '../services/api_service.dart';

class RewardProvider with ChangeNotifier {
  final ApiService _apiService;

  List<Reward> _rewards = [];
  bool _isLoading = false;
  String? _error;

  RewardProvider(this._apiService);

  List<Reward> get rewards => _rewards;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Reward> get activeRewards => _rewards.where((reward) => reward.isActive).toList();

  Future<void> fetchRewards() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _apiService.getRewards();
      _rewards = data.map((json) => Reward.fromJson(json)).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createReward(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.createReward(data);
      final newReward = Reward.fromJson(response);
      _rewards.add(newReward);
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

  Reward? getRewardById(int id) {
    try {
      return _rewards.firstWhere((reward) => reward.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Reward> getRewardsByType(String type) {
    return _rewards.where((reward) => reward.type == type).toList();
  }

  List<Reward> getRewardsByProgram(int rewardProgramId) {
    return _rewards.where((reward) => reward.rewardProgramId == rewardProgramId).toList();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void refresh() {
    fetchRewards();
  }
} 