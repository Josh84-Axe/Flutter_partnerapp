import 'package:dio/dio.dart';

void main() async {
  final dio = Dio(BaseOptions(
    baseUrl: 'https://api.tiknetafrica.com/v1',
    headers: {'Content-Type': 'application/json'},
    validateStatus: (status) => true,
  ));

  // Login
  final loginResp = await dio.post('/partner/login/', data: {
    'email': 'sientey@hotmail.com',
    'password': 'MyStr0ng!Pass2025',
  });
  final token = loginResp.data['data']['access'];
  dio.options.headers['Authorization'] = 'Bearer $token';

  // Helper
  Future<void> probe(String url) async {
    print('\n--- probing $url ---');
    final resp = await dio.get(url);
    if (resp.data is Map && resp.data['data'] is Map && resp.data['data']['results'] is List) {
       List list = resp.data['data']['results'];
       if (list.isNotEmpty) {
         print('Keys: ${list.first.keys.toList()}');
         print('Sample: ${list.first}');
       } else {
         print('Empty list');
       }
    } else if (resp.data is List && resp.data.isNotEmpty) {
       print('Keys: ${resp.data.first.keys.toList()}');
       print('Sample: ${resp.data.first}');
    } else if (resp.data is Map) {
       // Handle cases where the root is a map but might not have 'data' key structured as expected for other endpoints, or it is directly the data.
       print('Root Map Keys: ${resp.data.keys.toList()}');
       if (resp.data['data'] != null) {
          print('Inner Data Type: ${resp.data['data'].runtimeType}');
          if (resp.data['data'] is List && resp.data['data'].isNotEmpty) {
             print('Inner List Keys: ${resp.data['data'].first.keys.toList()}');
             print('Inner Sample: ${resp.data['data'].first}');
          } else {
             print('Inner Data Content: ${resp.data['data']}');
          }
       }
    } else {
       print('Unexpected format or empty: ${resp.data.runtimeType}');
    }
  }

  await probe('/partner/purchased-plans/');
  await probe('/partner/assigned-plans/');
  await probe('/partner/sessions/active/');
}
