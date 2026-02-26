
import 'package:dio/dio.dart';

void main() async {
  final dio = Dio(BaseOptions(
    baseUrl: 'https://api.tiknetafrica.com/v1',
    validateStatus: (status) => true,
  ));

  const String email = 'tiknetguinee@gmail.com';
  const String password = 'Testing987';

  print('🔐 Logging in as $email...');

  try {
    final loginResponse = await dio.post(
      '/partner/login/',
      data: {
        'email': email,
        'password': password,
      },
    );

    print('Login Status: ${loginResponse.statusCode}');
    print('Login Response Data: ${loginResponse.data}');
    if (loginResponse.statusCode != 200) {
      print('Login Failed: ${loginResponse.data}');
      return;
    }

    final data = loginResponse.data['data'];
    final String? accessToken = data['access'];

    if (accessToken == null) {
      print('No access token found in response');
      return;
    }

    print('✅ Login successful. Fetching profile...');

    final profileResponse = await dio.get(
      '/partner/profile/',
      options: Options(
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      ),
    );

    print('\n👤 PROFILE DATA:');
    print(profileResponse.data);

    final profileData = profileResponse.data['data'];
    if (profileData == null) {
      print('No profile data found in response');
      return;
    }

    print('\nChecking for project-related fields:');
    profileData.forEach((key, value) {
      if (key.contains('project') || key.contains('uuid') || key.contains('id')) {
        print('$key: $value');
      }
    });

  } catch (e) {
    print('\n❌ Error: $e');
  }
}
