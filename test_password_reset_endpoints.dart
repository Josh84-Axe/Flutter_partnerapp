import 'package:dio/dio.dart';

void main() async {
  final dio = Dio(BaseOptions(
    baseUrl: 'https://api.tiknetafrica.com/v1',
    headers: {
      'Content-Type': 'application/json',
    },
  ));

  print('🔍 Testing Password Reset Endpoints\n');
  
  // Test 1: Request password reset (should send OTP)
  print('📧 TEST 1: Request password reset');
  print('Endpoint: POST /partner/password-reset/request/');
  print('Expected payload: { "email": "user@example.com" }');
  
  try {
    final response = await dio.post('/partner/password-reset/request/', data: {
      'email': 'test@example.com',
    });
    print('✅ Response: ${response.data}');
  } catch (e) {
    if (e is DioException) {
      print('Status: ${e.response?.statusCode}');
      print('Response: ${e.response?.data}');
      
      // Try alternative endpoints
      print('\n🔄 Trying alternative: POST /partner/forgot-password/');
      try {
        final alt = await dio.post('/partner/forgot-password/', data: {
          'email': 'test@example.com',
        });
        print('✅ Response: ${alt.data}');
      } catch (e2) {
        if (e2 is DioException) {
          print('Status: ${e2.response?.statusCode}');
          print('Response: ${e2.response?.data}');
        }
      }
      
      print('\n🔄 Trying alternative: POST /partner/request-password-reset/');
      try {
        final alt2 = await dio.post('/partner/request-password-reset/', data: {
          'email': 'test@example.com',
        });
        print('✅ Response: ${alt2.data}');
      } catch (e3) {
        if (e3 is DioException) {
          print('Status: ${e3.response?.statusCode}');
          print('Response: ${e3.response?.data}');
        }
      }
    }
  }
  
  // Test 2: Verify OTP
  print('\n\n🔐 TEST 2: Verify OTP');
  print('Endpoint: POST /partner/password-reset/verify-otp/');
  print('Expected payload: { "email": "user@example.com", "otp": "123456" }');
  
  // Test 3: Reset password
  print('\n\n🔑 TEST 3: Reset password');
  print('Endpoint: POST /partner/password-reset/confirm/');
  print('Expected payload: { "email": "user@example.com", "otp": "123456", "new_password": "newpass" }');
  
  // Check auth repository for existing endpoints
  print('\n\n📚 Checking common password reset endpoint patterns:');
  final endpoints = [
    '/partner/password/reset/',
    '/partner/reset-password/',
    '/partner/auth/password-reset/',
    '/partner/auth/forgot-password/',
    '/password-reset/request/',
    '/auth/password-reset/',
  ];
  
  for (final endpoint in endpoints) {
    print('  - $endpoint');
  }
}
