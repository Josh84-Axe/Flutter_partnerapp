import 'package:flutter/material.dart';
import '../models/campus_models.dart';
import '../services/campus_api_service.dart';

class CampusProvider extends ChangeNotifier {
  StudentProfile? _profile;
  List<CampusSchedule> _schedules = [];
  bool _isLoading = false;
  String? _error;

  StudentProfile? get profile => _profile;
  List<CampusSchedule> get schedules => _schedules;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _profile = await CampusApiService.fetchStudentProfile();
      _schedules = await CampusApiService.fetchSchedules();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> buyPass(int passId, String paymentMethod, String phoneNumber) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // triggers the payment gateway prompt
      await CampusApiService.buyPass(passId, paymentMethod, phoneNumber);
      
      // Optionally reload the profile afterwards to see updated quotas,
      // but usually the payment is asynchronous. 
      // await loadData(); 
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
