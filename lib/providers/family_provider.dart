import 'package:flutter/material.dart';
import '../models/family_models.dart';
import '../services/family_api_service.dart';

class FamilyProvider extends ChangeNotifier {
  List<FamilyDevice> _devices = [];
  List<Map<String, dynamic>> _groups = [];
  List<ContentPolicy> _policies = [];
  List<ScreenTimeRule> _rules = [];
  bool _isLoading = false;
  String? _error;
  DateTime? _lastFetch;

  List<FamilyDevice> get devices => _devices;
  List<Map<String, dynamic>> get groups => _groups;
  List<ContentPolicy> get policies => _policies;
  List<ScreenTimeRule> get rules => _rules;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadData({bool forceRefresh = false}) async {
    if (!forceRefresh && _lastFetch != null && DateTime.now().difference(_lastFetch!).inSeconds < 60) {
      return; // Return from cache
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        FamilyApiService.fetchGroups(),
        FamilyApiService.fetchDevices(),
        FamilyApiService.fetchPolicies(),
      ]);

      _groups = results[0] as List<Map<String, dynamic>>;
      _devices = results[1] as List<FamilyDevice>;
      _policies = results[2] as List<ContentPolicy>;
      
      // Fetch rules for all devices
      final List<ScreenTimeRule> allRules = [];
      await Future.wait(_devices.map((d) async {
        final rules = await FamilyApiService.fetchRulesForDevice(d.id);
        allRules.addAll(rules);
      }));
      _rules = allRules;

      _lastFetch = DateTime.now();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> toggleDevicePause(int deviceId, bool pause, {int? durationMinutes}) async {
    // Optimistic update
    final index = _devices.indexWhere((d) => d.id == deviceId);
    if (index == -1) return false;
    
    final originalDevice = _devices[index];
    final updatedDevice = FamilyDevice(
      id: originalDevice.id,
      groupId: originalDevice.groupId,
      deviceName: originalDevice.deviceName,
      macAddress: originalDevice.macAddress,
      isPaused: pause,
      isOnline: originalDevice.isOnline,
      pauseUntil: pause && durationMinutes != null 
          ? DateTime.now().add(Duration(minutes: durationMinutes))
          : originalDevice.pauseUntil,
      activePolicyId: originalDevice.activePolicyId,
      activePolicyName: originalDevice.activePolicyName,
    );
    
    _devices[index] = updatedDevice;
    notifyListeners();

    try {
      final success = await FamilyApiService.toggleDevicePause(
        deviceId, 
        pause: pause, 
        durationMinutes: durationMinutes,
      );
      
      if (!success) {
        // Revert on failure
        _devices[index] = originalDevice;
        _error = 'Failed to update device status';
        notifyListeners();
        return false;
      }
      return true;
    } catch (e) {
      // Revert on failure
      _devices[index] = originalDevice;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> pauseAllInternet(bool pause) async {
    _isLoading = true;
    _error = null;
    
    // Batch Optimistic Update
    final originalDevices = List<FamilyDevice>.from(_devices);
    for (int i = 0; i < _devices.length; i++) {
      _devices[i] = FamilyDevice(
        id: _devices[i].id,
        groupId: _devices[i].groupId,
        deviceName: _devices[i].deviceName,
        macAddress: _devices[i].macAddress,
        isPaused: pause,
        isOnline: _devices[i].isOnline,
        pauseUntil: null,
        activePolicyId: _devices[i].activePolicyId,
        activePolicyName: _devices[i].activePolicyName,
      );
    }
    notifyListeners();

    try {
      // Use the new batch endpoint on the backend
      final success = await FamilyApiService.pauseAllDevices(pause);
      
      if (!success) {
        _devices = originalDevices;
        _error = 'Failed to pause all devices';
        notifyListeners();
        return false;
      }
      return true;
    } catch (e) {
      _devices = originalDevices;
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> registerDevice(String deviceName, String macAddress, {int? policyId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Use the first group available, or default to 1 if none found
      final groupId = _groups.isNotEmpty ? _groups.first['id'] as int : 1;
      
      final newDevice = await FamilyApiService.registerDevice(
        groupId, 
        deviceName, 
        macAddress, 
        policyId: policyId,
      );
      _devices.add(newDevice);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> removeDevice(int deviceId) async {
    final index = _devices.indexWhere((d) => d.id == deviceId);
    if (index == -1) return false;

    // Optimistic removal
    final removed = _devices.removeAt(index);
    notifyListeners();

    try {
      final success = await FamilyApiService.deleteDevice(deviceId);
      if (!success) {
        // Revert
        _devices.insert(index, removed);
        _error = 'Failed to remove device';
        notifyListeners();
        return false;
      }
      return true;
    } catch (e) {
      _devices.insert(index, removed);
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<bool> setDevicePolicy(int deviceId, ContentPolicy policy) async {
    final index = _devices.indexWhere((d) => d.id == deviceId);
    if (index == -1) return false;

    final originalDevice = _devices[index];
    _devices[index] = originalDevice.copyWith(
      activePolicyId: policy.id,
      activePolicyName: policy.name,
    );
    notifyListeners();

    try {
      final success = await FamilyApiService.updateDevicePolicy(deviceId, policy.id);
      if (!success) {
        _devices[index] = originalDevice;
        _error = 'Failed to update content policy';
        notifyListeners();
        return false;
      }
      return true;
    } catch (e) {
      _devices[index] = originalDevice;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // --- Screen Time Rules ---

  Future<bool> addRule(ScreenTimeRule rule) async {
    _isLoading = true;
    notifyListeners();
    try {
      final created = await FamilyApiService.createRule(rule.deviceId, rule);
      _rules.add(created);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateRule(ScreenTimeRule rule) async {
    final index = _rules.indexWhere((r) => r.id == rule.id);
    if (index == -1) return false;

    final original = _rules[index];
    _rules[index] = rule;
    notifyListeners();

    try {
      final success = await FamilyApiService.updateRule(rule.deviceId, rule.id, rule.toJson());
      if (!success) {
        _rules[index] = original;
        notifyListeners();
      }
      return success;
    } catch (e) {
      _rules[index] = original;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteRule(ScreenTimeRule rule) async {
    final index = _rules.indexWhere((r) => r.id == rule.id);
    if (index == -1) return false;

    final removed = _rules.removeAt(index);
    notifyListeners();

    try {
      final success = await FamilyApiService.deleteRule(rule.deviceId, rule.id);
      if (!success) {
        _rules.insert(index, removed);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _rules.insert(index, removed);
      notifyListeners();
      return false;
    }
  }

  String _wifiSsid = 'Tiknet_Family';
  String _wifiPassphrase = 'TiknetFamily123!';
  String get wifiSsid => _wifiSsid;
  String get wifiPassphrase => _wifiPassphrase;

  Future<void> fetchWifiSettings() async {
    final data = await FamilyApiService.fetchWifiSettings();
    if (data != null) {
      _wifiSsid = data['wifi_ssid'] ?? _wifiSsid;
      _wifiPassphrase = data['wifi_passphrase'] ?? _wifiPassphrase;
      notifyListeners();
    }
  }

  Future<bool> updateWifiSettings(String ssid, String passphrase) async {
    final success = await FamilyApiService.updateWifiSettings(ssid, passphrase);
    if (success) {
      _wifiSsid = ssid;
      _wifiPassphrase = passphrase;
      notifyListeners();
    }
    return success;
  }
}

