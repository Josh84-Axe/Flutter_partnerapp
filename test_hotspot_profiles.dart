import 'package:dio/dio.dart';

void main() async {
  final dio = Dio(BaseOptions(
    baseUrl: 'https://api.tiknetafrica.com/v1',
    headers: {
      'Content-Type': 'application/json',
    },
  ));

  try {
    // Login first
    print('🔐 Logging in...');
    final loginResponse = await dio.post('/partner/login/', data: {
      'email': 'sientey@hotmail.com',
      'password': 'Testing123',
    });
    
    final accessToken = loginResponse.data['data']['access'];
    print('✅ Login successful, got token');
    
    // Set token for subsequent requests
    dio.options.headers['Authorization'] = 'Bearer $accessToken';
    
    // Fetch hotspot profiles
    print('\n🔥 Fetching hotspot profiles from /partner/hotspot/profiles/list/');
    final profilesResponse = await dio.get('/partner/hotspot/profiles/list/');
    
    print('\n📦 Full Response:');
    print(profilesResponse.data);
    
    print('\n📊 Response Structure:');
    print('Type: ${profilesResponse.data.runtimeType}');
    
    if (profilesResponse.data is Map) {
      final data = profilesResponse.data as Map;
      print('Keys: ${data.keys.toList()}');
      
      if (data['data'] != null) {
        print('\ndata field type: ${data['data'].runtimeType}');
        if (data['data'] is Map) {
          print('data keys: ${(data['data'] as Map).keys.toList()}');
          if (data['data']['results'] != null) {
            print('results type: ${data['data']['results'].runtimeType}');
            if (data['data']['results'] is List) {
              final results = data['data']['results'] as List;
              print('Number of profiles: ${results.length}');
              if (results.isNotEmpty) {
                print('\n🎯 First profile structure:');
                print(results[0]);
              }
            }
          }
        } else if (data['data'] is List) {
          final profiles = data['data'] as List;
          print('Number of profiles: ${profiles.length}');
          if (profiles.isNotEmpty) {
            print('\n🎯 First profile structure:');
            print(profiles[0]);
          }
        }
      }
    }
    
  } catch (e) {
    print('❌ Error: $e');
    if (e is DioException) {
      print('Response: ${e.response?.data}');
    }
  }
}
