import 'package:dio/dio.dart';

void main() async {
  final dio = Dio(BaseOptions(
    baseUrl: 'https://api.tiknetafrica.com',
    headers: {
      'Authorization': 'Token aPuOwuzgw2HWPiWuVM5AcwexsVNiKKJkqEWXFHN2nHE',
    },
  ));

  try {
    print('Testing login...');
    final loginRes = await dio.post('/partner/login/', data: {
      'email': 'sientey@hotmail.com',
      'password': 'MyStr0ng!Pass2026',
    });
    
    final token = loginRes.data['token'];
    print('Login successful. Token: $token');
    
    dio.options.headers['Authorization'] = 'Token $token';
    
    print('Fetching profile...');
    final profileRes = await dio.get('/partner/profile/');
    print('Profile Data:');
    print(profileRes.data);
  } catch (e) {
    print('Error: $e');
  }
}
