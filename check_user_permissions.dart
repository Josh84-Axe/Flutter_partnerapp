import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Quick script to check user role and permissions
/// Run with: dart run check_user_permissions.dart
void main() async {
  final dio = Dio(BaseOptions(
    baseUrl: 'https://hotspot.sientey.com',
    headers: {
      'Content-Type': 'application/json',
    },
  ));

  try {
    print('🔐 Logging in as sientey@hotmail.com...');
    
    final loginResponse = await dio.post('/partner/login/', data: {
      'email': 'sientey@hotmail.com',
      'password': 'Testing123', // Update if password is different
    });

    if (loginResponse.statusCode == 200) {
      final data = loginResponse.data;
      
      print('\n✅ Login successful!\n');
      print('📋 User Information:');
      print('   Email: ${data['email']}');
      print('   Name: ${data['name']}');
      print('   Role: ${data['role']}');
      print('   Permissions: ${data['permissions']}');
      print('   Is Active: ${data['is_active']}');
      
      if (data['permissions'] is List) {
        print('\n🔍 Permission Analysis:');
        final perms = data['permissions'] as List;
        if (perms.isEmpty) {
          print('   ⚠️  No permissions assigned');
        } else if (perms.first is int) {
          print('   ⚠️  Permissions are IDs (need mapping): $perms');
        } else {
          print('   ✅ Permissions are codenames:');
          for (var perm in perms) {
            print('      - $perm');
          }
        }
      }
      
      print('\n🎭 Role Analysis:');
      if (data['role'] == 'Administrator' || data['role'] == 'owner') {
        print('   ✅ User is an Administrator (full access)');
      } else {
        print('   ℹ️  User role: ${data['role']}');
        print('   ℹ️  Access is permission-based');
      }
    }
  } catch (e) {
    print('❌ Error: $e');
    if (e is DioException) {
      print('Response: ${e.response?.data}');
    }
  }
}
