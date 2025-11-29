import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Quick test script to check active sessions endpoint
/// Run this to see what the API actually returns
void main() async {
  final dio = Dio(BaseOptions(
    baseUrl: 'https://api.tiknetafrica.com/v1',
    headers: {
      'Content-Type': 'application/json',
      // You'll need to add your auth token here
      // 'Authorization': 'Bearer YOUR_TOKEN_HERE',
    },
  ));

  try {
    print('🔄 Testing /partner/sessions/active/');
    final response = await dio.get('/partner/sessions/active/');
    
    print('\n📊 Response Status: ${response.statusCode}');
    print('📦 Response Data Type: ${response.data.runtimeType}');
    print('📦 Full Response:');
    print(response.data);
    
    if (response.data is Map) {
      final data = response.data as Map;
      print('\n🔍 Response Keys: ${data.keys.toList()}');
      
      if (data.containsKey('data')) {
        print('✅ Has "data" key');
        print('   Data type: ${data['data'].runtimeType}');
        if (data['data'] is List) {
          print('   List length: ${(data['data'] as List).length}');
          if ((data['data'] as List).isNotEmpty) {
            print('   First item: ${(data['data'] as List).first}');
          }
        }
      } else {
        print('⚠️  No "data" key found');
      }
    }
  } catch (e) {
    print('❌ Error: $e');
    if (e is DioException) {
      print('   Status Code: ${e.response?.statusCode}');
      print('   Response: ${e.response?.data}');
    }
  }
}
