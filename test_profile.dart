import 'dart:convert';
import 'package:dio/dio.dart';

void main() async {
  final dio = Dio(BaseOptions(
    baseUrl: 'https://staging.wifi-4u.net/v1',
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
    validateStatus: (status) => true,
  ));

  print('1. Authenticating...');
  final loginRes = await dio.post('/partner/login/', data: {
    'email': 'sientey@hotmail.com',
    'password': 'MyStr0ng!Pass2025'
  });

  final loginData = loginRes.data['data'];
  print('Login Data: $loginData');
}
