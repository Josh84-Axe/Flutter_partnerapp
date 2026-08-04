import 'dart:convert';
import 'dart:io';

void main() async {
  final email = 'campus.test1@wifi-4u.net';
  final otp = '301604';
  
  final url = Uri.parse('https://staging.wifi-4u.net/v1/auth/verify-otp/');
  
  try {
    final client = HttpClient();
    final request = await client.postUrl(url);
    
    request.headers.set('content-type', 'application/json');
    request.add(utf8.encode(jsonEncode({
      'email': email,
      'otp': otp
    })));
    
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    print('Status: ${response.statusCode}');
    print('Response: $responseBody');
    
    client.close();
  } catch (e) {
    print('Error: $e');
  }
}
