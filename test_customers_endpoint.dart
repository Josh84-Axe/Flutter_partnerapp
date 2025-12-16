import 'package:dio/dio.dart';

void main() async {
  final dio = Dio(BaseOptions(
    baseUrl: 'https://api.tiknetafrica.com/v1',
    headers: {'Content-Type': 'application/json'},
    validateStatus: (status) => true,
  ));

  print('🔐 Logging in...');
  final loginResponse = await dio.post('/partner/login/', data: {
    'email': 'sientey@hotmail.com',
    'password': 'MyStr0ng!Pass2025',
  });
  final accessToken = loginResponse.data['data']['access'];
  dio.options.headers['Authorization'] = 'Bearer $accessToken';

  print('🔍 Probing /partner/customers/');
  final response = await dio.get('/partner/customers/');
  print('Status: ${response.statusCode}');
  print('Data Type: ${response.data.runtimeType}');
  print('Raw Data: ${response.data}');
}
