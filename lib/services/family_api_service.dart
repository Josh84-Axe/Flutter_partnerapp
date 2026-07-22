import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api/api_config.dart';
import '../locator.dart';
import 'api/token_storage.dart';
import '../models/family_models.dart';

class FamilyApiService {
  static String get baseUrl => ApiConfig.baseUrl;

  static Future<Map<String, String>> _getHeaders() async {
    final tokenStorage = locator<TokenStorage>();
    final token = await tokenStorage.getAccessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<String> checkRouterVariant(String dnsName) async {
    final response = await http.get(Uri.parse("$baseUrl/customer/router-partner-info/?dns_name=$dnsName"));
    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      return body['data']['app_variant'] ?? 'partner';
    }
    return 'partner';
  }

  static Future<List<Map<String, dynamic>>> fetchGroups() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/family/groups/'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        final List<dynamic> list = body['data'] ?? [];
        return List<Map<String, dynamic>>.from(list);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<FamilyDevice>> fetchDevices() async {
    final response = await http.get(
      Uri.parse('$baseUrl/family/devices/'),
      headers: await _getHeaders(),
    );
    
    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      final List<dynamic> list = body['data'] ?? [];
      return list.map((json) => FamilyDevice.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load family devices');
    }
  }

  static Future<FamilyDevice> registerDevice(int groupId, String deviceName, String macAddress, {int? policyId}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/family/devices/'),
      headers: await _getHeaders(),
      body: json.encode({
        'group_id': groupId,
        'device_name': deviceName,
        'mac_address': macAddress,
        if (policyId != null) 'policy_id': policyId,
      }),
    );

    if (response.statusCode == 201) {
      final body = json.decode(response.body);
      return FamilyDevice.fromJson(body['data']);
    } else {
      final body = json.decode(response.body);
      throw Exception(body['message'] ?? 'Failed to register device');
    }
  }

  static Future<bool> toggleDevicePause(int deviceId, {bool pause = true, int? durationMinutes}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/family/devices/$deviceId/pause/'),
      headers: await _getHeaders(),
      body: json.encode({
        'action': pause ? 'pause' : 'unpause',
        if (durationMinutes != null) 'duration_minutes': durationMinutes,
      }),
    );

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
    final response = await http.post(
      Uri.parse('$baseUrl/family/schedules/'),
      headers: await _getHeaders(),
      body: json.encode({
        'device_id': deviceId,
        'name': name,
        'day_of_week': dayOfWeek,
        'start_time': startTime,
        'end_time': endTime,
        'policy_id': policyId,
      }),
    );

    if (response.statusCode == 201) {
      final body = json.decode(response.body);
      return PolicySchedule.fromJson(body['data']);
    } else {
      final body = json.decode(response.body);
      throw Exception(body['message'] ?? 'Failed to create schedule');
    }
  }

  static Future<List<ContentPolicy>> fetchPolicies() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/family/policies/'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        final List<dynamic> list = body['data'] ?? [];
        return list.map((json) => ContentPolicy.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<bool> updateDevicePolicy(int deviceId, int policyId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/family/devices/$deviceId/policy/'),
      headers: await _getHeaders(),
      body: json.encode({
        'policy_id': policyId,
      }),
    );

    return response.statusCode == 200;
  }

  static Future<List<UnclaimedDevice>> fetchUnclaimedDevices() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/family/network/unclaimed/'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        final List<dynamic> list = body['data'] ?? [];
        return list.map((json) => UnclaimedDevice.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
