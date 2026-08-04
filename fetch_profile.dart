import 'package:dio/dio.dart';
import 'package:hotspot_partner_app/services/api/api_config.dart';

void main() async {
  final dio = Dio(BaseOptions(
    baseUrl: ApiConfig.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  try {
    print('Logging in...');
    final loginResponse = await dio.post('/partner/login/', data: {
      'email': 'sientey@hotmail.com',
      'password': 'Testing123',
    });

    final token = loginResponse.data['data']['access'];
    print('Login successful. Token: ${token.substring(0, 10)}...');

    print('Fetching profile...');
    final profileResponse = await dio.get(
      '/partner/profile/',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    print('Profile Response:');
    print(profileResponse.data);
  } catch (e) {
    if (e is DioException) {
      print('Error: ${e.message}');
      print('Response: ${e.response?.data}');
    } else {
      print('Error: $e');
    }
  }
}
