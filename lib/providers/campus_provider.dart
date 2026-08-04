import 'package:flutter/material.dart';
import '../models/campus_models.dart';
import '../services/campus_api_service.dart';

class CampusProvider extends ChangeNotifier {
  StudentProfile? _profile;
  List<CampusSchedule> _schedules = [];
  List<DataPass> _passes = [];
  List<WifiZone> _wifiZones = [];
  bool _isLoading = false;
  String? _error;

  StudentProfile? get profile => _profile;
  List<CampusSchedule> get schedules => _schedules;
  List<DataPass> get passes => _passes;
  List<WifiZone> get wifiZones => _wifiZones;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _profile = await CampusApiService.fetchStudentProfile();
      _schedules = await CampusApiService.fetchSchedules();
      _passes = await CampusApiService.fetchPasses();
      _wifiZones = await CampusApiService.fetchWifiZones();
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
      await CampusApiService.buyPass(passId, paymentMethod, phoneNumber);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitSupportTicket(String issueType, String description) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await CampusApiService.submitSupportTicket(issueType, description);
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
