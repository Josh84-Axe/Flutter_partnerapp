import 'package:flutter/material.dart';
import '../models/family_models.dart';
import '../services/family_api_service.dart';

class FamilyProvider extends ChangeNotifier {
  List<FamilyDevice> _devices = [];
  List<Map<String, dynamic>> _groups = [];
  List<ContentPolicy> _policies = [];
  bool _isLoading = false;
  String? _error;

  List<FamilyDevice> get devices => _devices;
  List<Map<String, dynamic>> get groups => _groups;
  List<ContentPolicy> get policies => _policies;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _groups = await FamilyApiService.fetchGroups();
      _devices = await FamilyApiService.fetchDevices();
      _policies = await FamilyApiService.fetchPolicies();
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
    notifyListeners();

    try {
      // Create a list of futures to pause all devices concurrently
      final futures = _devices.map((device) {
        return toggleDevicePause(device.id, pause);
      }).toList();
      
      final results = await Future.wait(futures);
      
      // If any failed, we return false, but we still tried all of them.
      return !results.contains(false);
    } catch (e) {
      _error = e.toString();
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

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<bool> setDevicePolicy(int deviceId, ContentPolicy policy) async {
    final index = _devices.indexWhere((d) => d.id == deviceId);
    if (index == -1) return false;

    final originalDevice = _devices[index];
    final updatedDevice = FamilyDevice(
      id: originalDevice.id,
      groupId: originalDevice.groupId,
      deviceName: originalDevice.deviceName,
      macAddress: originalDevice.macAddress,
      isPaused: originalDevice.isPaused,
      pauseUntil: originalDevice.pauseUntil,
      activePolicyId: policy.id,
      activePolicyName: policy.name,
    );

    _devices[index] = updatedDevice;
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
}
