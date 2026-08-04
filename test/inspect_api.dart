import 'package:dio/dio.dart';
import 'dart:convert';

void main() async {
  final dio = Dio(BaseOptions(
    baseUrl: 'https://api.tiknetafrica.com',
    headers: {
      'Authorization': 'Token aPuOwuzgw2HWPiWuVM5AcwexsVNiKKJkqEWXFHN2nHE',
    },
  ));

  try {
    print('--- LOGGING IN ---');
    final loginRes = await dio.post('/partner/login/', data: {
      'email': 'sientey@hotmail.com',
      'password': 'MyStr0ng!Pass2026',
    });
    
    final token = loginRes.data['token'];
    print('Login successful. Token: $token');
    print('User in login response:');
    print(jsonEncode(loginRes.data['user']));
    
    dio.options.headers['Authorization'] = 'Token $token';
    
    print('\n--- FETCHING PROFILE ---');
    final profileRes = await dio.get('/partner/profile/');
    print('Profile Data:');
    print(jsonEncode(profileRes.data));
    
    print('\n--- FETCHING PLANS ---');
    final plansRes = await dio.get('/partner/plans/internet_plans/');
    print('Plans Data (first one):');
    if (plansRes.data is List && plansRes.data.isNotEmpty) {
      print(jsonEncode(plansRes.data[0]));
    } else {
      print('No plans or unexpected format: ${plansRes.data}');
    }
  } catch (e) {
    print('Error: $e');
  }
}
