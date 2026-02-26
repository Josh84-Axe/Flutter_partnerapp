
import 'package:dio/dio.dart';

void main() async {
  final dio = Dio();
  const baseUrl = 'https://api.coleah.com/api/cases/external/cases/';
  const email = 'tiknetguinee@gmail.com';

  final keys = [
    {'name': 'QNBBRFCO... (Current Config)', 'key': 'QNBBRFCO0rfnxFxS9buqx2cMjTbDwQEd3Zwhew_TXMI'},
    {'name': 'aPuOwuzgw2... (Old/Test Key)', 'key': 'aPuOwuzgw2HWPiWuVM5AcwexsVNiKKJkqEWXFHN2nHE'},
  ];

  for (var keyInfo in keys) {
    print('\n🔑 Testing Key: ${keyInfo['name']}');
    try {
      final response = await dio.get(
        baseUrl,
        queryParameters: {'contact_email': email},
        options: Options(
          headers: {
            'X-Api-Key': keyInfo['key']!.trim(),
          },
          validateStatus: (status) => true,
        ),
      );

      print('📊 Status Code: ${response.statusCode}');
      if (response.statusCode == 200) {
        final List tickets = response.data is List ? response.data : [];
        print('✅ Found ${tickets.length} tickets.');
        for (var ticket in tickets) {
          print(' - [#${ticket['id']}] ${ticket['subject']} (Status: ${ticket['status']})');
        }
      } else {
        print('❌ Error response: ${response.data}');
      }
    } catch (e) {
      print('❌ Request Failed: $e');
    }
  }
}
