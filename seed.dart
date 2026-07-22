import 'package:dio/dio.dart';
import 'dart:io';

void main() async {
  final dio = Dio(BaseOptions(
    baseUrl: 'https://staging.wifi-4u.net/v1',
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  final email = 'sientey@hotmail.com';
  final password = 'MyStr0ng!Pass2025';

  print('1. Authenticating $email...');
  try {
    final authRes = await dio.post('/partner/login/', data: {
      'email': email,
      'password': password,
    });
    
    final token = authRes.data['data']['access'];
    print('✅ JWT Acquired');
    
    dio.options.headers['Authorization'] = 'Bearer $token';
    
    print('2. Fetching Unclaimed Devices...');
    final unRes = await dio.get('/family/network/unclaimed/');
    final unData = unRes.data['data'] ?? unRes.data;
    print('✅ Unclaimed devices response: ${unRes.statusCode} (List size: ${(unData as List).length})');

    print('3. Fetching Family Groups...');
    final groupsRes = await dio.get('/family/groups/');
    final groupsData = groupsRes.data['data'] ?? groupsRes.data;
    final groups = groupsData as List;
    final groupId = groups.isNotEmpty ? groups.first['id'] : 1;

    print('4. Claiming new mock device...');
    final randomMac = List.generate(6, (_) => (DateTime.now().microsecondsSinceEpoch % 256).toRadixString(16).padLeft(2, '0').toUpperCase()).join(':');
    final claimRes = await dio.post('/family/devices/', data: {
      'group_id': groupId,
      'device_name': "Fred's Seed Device",
      'mac_address': randomMac,
      'policy_id': 3 // Family Safe
    });
    final deviceData = claimRes.data['data'] ?? claimRes.data;
    final deviceId = deviceData['id'];
    print('✅ Device Claimed! ID: $deviceId');

    print('5. Updating Policy to CIPA Strict...');
    final polRes = await dio.post('/family/devices/$deviceId/policy/', data: {
      'policy_id': 4
    });
    final polData = polRes.data['data'] ?? polRes.data;
    print('✅ Policy updated! Policy: ${polData['active_policy_name']}');

    print('6. Injecting Schedule...');
    final schedRes = await dio.post('/family/schedules/', data: {
      'device_id': deviceId,
      'name': "Automated Bedtime",
      'day_of_week': 0,
      'start_time': "21:00:00",
      'end_time': "06:00:00",
      'policy_id': 3
    });
    final schedData = schedRes.data['data'] ?? schedRes.data;
    print('✅ Schedule Injected! Schedule ID: ${schedData['id']}');
    
    print('🎉 ALL VALIDATIONS PASSED!');
    exit(0);
  } on DioException catch (e) {
    print('❌ Failed: ${e.response?.statusCode}');
    print(e.response?.data);
    exit(1);
  }
}
