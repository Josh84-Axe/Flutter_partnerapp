import 'package:flutter/foundation.dart';
import '../locator.dart';
import 'package:dio/dio.dart';
import '../models/family_models.dart';

class FamilyApiService {
  static Future<String> checkRouterVariant(String dnsName) async {
    final response = await locator<Dio>().get('/customer/router-partner-info/?dns_name=$dnsName');
    if (response.statusCode == 200) {
      final body = response.data;
      return body['data']['app_variant'] ?? 'partner';
    }
    return 'partner';
  }

  static Future<List<Map<String, dynamic>>> fetchGroups() async {
    try {
      final response = await locator<Dio>().get('/groups/');

      if (response.statusCode == 200) {
        final body = response.data;
        final List<dynamic> list = body['data'] ?? [];
        return List<Map<String, dynamic>>.from(list);
      }
      return [];
    } catch (e) {
      if (e is DioException) {
        debugPrint('fetchGroups API ERROR: ${e.response?.data}');
      }
      return [];
    }
  }

  static Future<List<FamilyDevice>> fetchDevices() async {
    final response = await locator<Dio>().get('/devices/');
    
    if (response.statusCode == 200) {
      final body = response.data;
      final List<dynamic> list = body['data'] ?? [];
      return list.map((json) => FamilyDevice.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load family devices');
    }
  }

  static Future<FamilyDevice> registerDevice(int groupId, String deviceName, String macAddress, {int? policyId}) async {
    try {
      final response = await locator<Dio>().post('/devices/', data: {
        'group_id': groupId,
        'device_name': deviceName,
        'mac_address': macAddress,
        if (policyId != null) 'policy_id': policyId,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = response.data;
        return FamilyDevice.fromJson(body['data']);
      } else {
        final body = response.data;
        throw Exception(body['message'] ?? 'Failed to register device');
      }
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message ?? 'Failed to register device';
      throw Exception(msg);
    }
  }

  static Future<bool> toggleDevicePause(int deviceId, {bool pause = true, int? durationMinutes}) async {
    final response = await locator<Dio>().post('/devices/$deviceId/pause/', data: {
        'action': pause ? 'pause' : 'unpause',
        if (durationMinutes != null) 'duration_minutes': durationMinutes,
      });

    return response.statusCode == 200;
  }

  static Future<bool> pauseAllDevices(bool pause) async {
    final response = await locator<Dio>().post('/devices/pause-all/', data: {
        'action': pause ? 'pause' : 'unpause',
      });

    return response.statusCode == 200;
  }

  static Future<PolicySchedule> createSchedule(
    int deviceId,
    String name,
    int dayOfWeek,
    String startTime,
    String endTime,
    int policyId,
  ) async {
    final response = await locator<Dio>().post('/devices/$deviceId/schedules/', data: {
        'name': name,
        'day_of_week': dayOfWeek,
        'start_time': startTime,
        'end_time': endTime,
        'policy_id': policyId,
      });

    if (response.statusCode == 201) {
      final body = response.data;
      return PolicySchedule.fromJson(body['data']);
    } else {
      final body = response.data;
      throw Exception(body['message'] ?? 'Failed to create schedule');
    }
  }

  static Future<bool> toggleScheduleActive(int deviceId, int scheduleId, bool isActive) async {
    try {
      final dio = locator<Dio>();
      final response = await dio.patch(
        '/devices/$deviceId/schedules/$scheduleId/',
        data: {'is_active': isActive},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteSchedule(int deviceId, int scheduleId) async {
    try {
      final dio = locator<Dio>();
      final response = await dio.delete(
        '/devices/$deviceId/schedules/$scheduleId/',
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteDevice(int deviceId) async {
    try {
      final dio = locator<Dio>();
      final response = await dio.delete('/devices/$deviceId/');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<List<PolicySchedule>> fetchSchedulesForDevice(int deviceId) async {
    try {
      final dio = locator<Dio>();
      final response = await dio.get('/devices/$deviceId/schedules/');
      if (response.statusCode == 200) {
        final List<dynamic> list = response.data['data'] ?? [];
        return list.map((json) => PolicySchedule.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      if (e is DioException) {
        debugPrint('fetchSchedulesForDevice error: ${e.message}, data: ${e.response?.data}');
      }
      return [];
    }
  }

  static Future<List<PolicySchedule>> fetchAllSchedules(List<FamilyDevice> devices) async {
    final List<PolicySchedule> allSchedules = [];
    await Future.wait(devices.map((device) async {
      final schedules = await fetchSchedulesForDevice(device.id);
      allSchedules.addAll(schedules);
    }));
    return allSchedules;
  }

  // --- Screen Time Rules ---

  static Future<List<ScreenTimeRule>> fetchRulesForDevice(int deviceId) async {
    try {
      final dio = locator<Dio>();
      final response = await dio.get('/devices/$deviceId/rules/');
      if (response.statusCode == 200) {
        final List<dynamic> list = response.data['data'] ?? [];
        return list.map((json) => ScreenTimeRule.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<ScreenTimeRule> createRule(int deviceId, ScreenTimeRule rule) async {
    final dio = locator<Dio>();
    final response = await dio.post(
      '/devices/$deviceId/rules/',
      data: rule.toJson(),
    );

    if (response.statusCode == 201) {
      final body = response.data;
      final newId = body['data']['id'].toString();
      return ScreenTimeRule(
        id: newId,
        label: rule.label,
        deviceName: rule.deviceName,
        deviceId: rule.deviceId,
        dailyLimitMinutes: rule.dailyLimitMinutes,
        allowedDays: rule.allowedDays,
        accessStart: rule.accessStart,
        accessEnd: rule.accessEnd,
        isEnabled: rule.isEnabled,
      );
    } else {
      throw Exception(response.data['message'] ?? 'Failed to create rule');
    }
  }

  static Future<bool> updateRule(int deviceId, String ruleId, Map<String, dynamic> data) async {
    try {
      final dio = locator<Dio>();
      final response = await dio.patch(
        '/devices/$deviceId/rules/$ruleId/',
        data: data,
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteRule(int deviceId, String ruleId) async {
    try {
      final dio = locator<Dio>();
      final response = await dio.delete('/devices/$deviceId/rules/$ruleId/');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<List<ContentPolicy>> fetchPolicies() async {
    try {
      final response = await locator<Dio>().get('/policies/');

      if (response.statusCode == 200) {
        final body = response.data;
        final List<dynamic> list = body['data'] ?? [];
        return list.map((json) => ContentPolicy.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<bool> updateDevicePolicy(int deviceId, int policyId) async {
    try {
      final response = await locator<Dio>().post('/devices/$deviceId/policy/', data: {
        'policy_id': policyId,
      });

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('updateDevicePolicy error: $e');
      return false;
    }
  }

  static Future<List<UnclaimedDevice>> fetchUnclaimedDevices() async {
    try {
      final dio = locator<Dio>();
      final response = await dio.get('/network/unclaimed/');

      if (response.statusCode == 200) {
        final List<dynamic> list = response.data['data'] ?? [];
        return list.map((json) => UnclaimedDevice.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      if (e is DioException) {
        debugPrint('fetchUnclaimedDevices Dio error: ${e.message} - ${e.response?.data}');
      } else {
        debugPrint('fetchUnclaimedDevices error: $e');
      }
      return [];
    }
  }

  static Future<Map<String, dynamic>?> fetchWifiSettings() async {
    try {
      final response = await locator<Dio>().get('/router/wifi-settings/');
      if (response.statusCode == 200 && response.data['data'] != null) {
        return Map<String, dynamic>.from(response.data['data']);
      }
      return null;
    } catch (e) {
      debugPrint('fetchWifiSettings error: $e');
      return null;
    }
  }

  static Future<bool> updateWifiSettings(String ssid, String passphrase) async {
    try {
      final response = await locator<Dio>().post('/router/wifi-settings/', data: {
        'wifi_ssid': ssid,
        'wifi_passphrase': passphrase,
      });
      return response.statusCode == 200 && response.data['error'] == false;
    } catch (e) {
      debugPrint('updateWifiSettings error: $e');
      return false;
    }
  }
}
