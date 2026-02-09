import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Check User Profile for Vouchers', () async {
    final dio = Dio(BaseOptions(
      baseUrl: 'https://api.tiknetafrica.com/v1',
      headers: {'Content-Type': 'application/json'},
    ));

    print('1. Logging in...');
    final loginRes = await dio.post('/partner/login/', data: {
      'email': 'sientey@hotmail.com',
      'password': 'MyStr0ng!Pass2026',
    });
    final data = loginRes.data['data'];
    final token = data['access'];
    dio.options.headers['Authorization'] = 'Bearer $token';

    print('2. Enabling smart vouchers...');
    try {
      final updateRes = await dio.put('/partner/profile/update/', data: {
        'enable_smart_vouchers': true,
      });
      print('Update Response: ${updateRes.data}');
    } catch (e) {
      print('Update failed: $e');
    }
  });
}
