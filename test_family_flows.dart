import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final baseUrl = 'https://staging.wifi-4u.net/v1';
  final email = 'campus.test1@wifi-4u.net';
  final password = 'password123'; // Guessing the password
  final otp = '301604';

  print('Attempting login with $email...');
  
  // Try normal login
  final loginRes = await http.post(
    Uri.parse('$baseUrl/partner/login/'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'email': email,
      'password': otp, // Maybe OTP is the password?
      'variant': 'campus',
    }),
  );

  print('Login status: ${loginRes.statusCode}');
  print('Login response: ${loginRes.body}');
}
