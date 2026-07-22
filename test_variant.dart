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

  try {
    final authRes = await dio.post('/partner/login/', data: {
      'email': email,
      'password': password,
    });
    
    final token = authRes.data['data']['access'];
    final user = authRes.data['data']['user'];
    
    print('✅ JWT Acquired');
    print('User Object from Login: $user');
    
    dio.options.headers['Authorization'] = 'Bearer $token';
    
    final meRes = await dio.get('/partner/me/');
    print('Me API Response: ${meRes.data}');
    
    exit(0);
  } on DioException catch (e) {
    print('❌ Failed: ${e.response?.statusCode}');
    print(e.response?.data);
    exit(1);
  }
}
