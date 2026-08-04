
import 'package:dio/dio.dart';

void main() async {
  final dio = Dio();
  const baseUrl = 'https://api.coleah.com/api/cases/external/cases/';
  const apiKey = 'aPuOwuzgw2HWPiWuVM5AcwexsVNiKKJkqEWXFHN2nHE';
  const email = 'josh@tiknetafrica.com';

  print('🧪 Testing Ticket Listing for: $email');

  try {
    final response = await dio.get(
      baseUrl,
      queryParameters: {'contact_email': email},
      options: Options(
        headers: {
          'X-Api-Key': apiKey,
        },
      ),
    );

    print('📊 Status Code: ${response.statusCode}');
    if (response.statusCode == 200) {
      final List tickets = response.data;
      print('✅ Found ${tickets.length} tickets.');
      for (var ticket in tickets) {
        print(' - [#${ticket['id'].toString().substring(0, 8)}] ${ticket['subject']} (Status: ${ticket['status']})');
      }
      
      // Check if our specific test ticket is there
      final hasTestTicket = tickets.any((t) => t['subject'].contains('Listing Investigation'));
      if (hasTestTicket) {
        print('🌟 SUCCESS: Test ticket found in filtered list!');
      } else {
        print('⚠️ WARNING: Test ticket NOT found in list. Checking without filter...');
        final fullList = await dio.get(baseUrl, options: Options(headers: {'X-Api-Key': apiKey}));
        print('🔍 Full list size: ${fullList.data.length}');
      }
    } else {
      print('❌ Failed to fetch tickets: ${response.data}');
    }
  } catch (e) {
    print('❌ Error: $e');
  }
}
