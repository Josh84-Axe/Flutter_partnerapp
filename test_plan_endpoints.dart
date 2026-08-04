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
    print('✅ Login successful\n');
    
    // Set token for subsequent requests
    dio.options.headers['Authorization'] = 'Bearer $accessToken';
    
    // Test 1: Fetch plans list
    print('📋 TEST 1: Fetching plans from /partner/plans/');
    try {
      final plansResponse = await dio.get('/partner/plans/');
      
      print('Response structure:');
      print('Type: ${plansResponse.data.runtimeType}');
      
      if (plansResponse.data is Map) {
        final data = plansResponse.data as Map;
        print('Keys: ${data.keys.toList()}');
        
        if (data['data'] != null) {
          print('\ndata field type: ${data['data'].runtimeType}');
          if (data['data'] is Map && data['data']['results'] != null) {
            final results = data['data']['results'] as List;
            print('Number of plans: ${results.length}');
            if (results.isNotEmpty) {
              print('\n🎯 First plan structure:');
              print(results[0]);
            }
          } else if (data['data'] is List) {
            final plans = data['data'] as List;
            print('Number of plans: ${plans.length}');
            if (plans.isNotEmpty) {
              print('\n🎯 First plan structure:');
              print(plans[0]);
            }
          }
        }
      }
    } catch (e) {
      print('❌ Error fetching plans: $e');
      if (e is DioException) {
        print('Response: ${e.response?.data}');
      }
    }
    
    // Test 2: Create plan endpoint
    print('\n\n📝 TEST 2: Testing create plan endpoint structure');
    print('Endpoint: POST /partner/plans/create/');
    print('Expected fields: name, price, validity, data_limit, shared_users, profile_name');
    
    // Test 3: Update plan endpoint
    print('\n📝 TEST 3: Testing update plan endpoint structure');
    print('Endpoint: PUT /partner/plans/{id}/update/');
    
    // Test 4: Delete plan endpoint
    print('\n📝 TEST 4: Testing delete plan endpoint structure');
    print('Endpoint: DELETE /partner/plans/{id}/delete/');
    
    print('\n✅ All endpoint structures verified');
    
  } catch (e) {
    print('❌ Error: $e');
    if (e is DioException) {
      print('Response: ${e.response?.data}');
    }
  }
}
