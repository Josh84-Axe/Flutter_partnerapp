
import 'package:dio/dio.dart';

void main() async {
  print('🧪 Verifying Coleah Support Ticket API (Pure Dart)...');
  
  final dio = Dio();
  const url = 'https://api.coleah.com/api/cases/external/cases/';
  
  try {
    print('🚀 Sending test request to $url...');
    final response = await dio.post(
      url,
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'X-Api-Key': ' aPuOwuzgw2HWPiWuVM5AcwexsVNiKKJkqEWXFHN2nHE', // Trying with space per prompt
        },
        validateStatus: (status) => true,
      ),
      data: {
        'subject': 'Automated API Verification',
        'description': 'Verifying API connectivity from Partner App dev environment.',
        'contact_name': 'Antigravity Verification',
        'contact_email': 'verification@tiknetafrica.com',
        'priority': 'MEDIUM',
      },
    );

    if (response.statusCode == 201) {
      print('✅ SUCCESS: Ticket created! Response: ${response.data}');
    } else {
      print('❌ FAILED: Status ${response.statusCode} - ${response.data}');
    }

  } catch (e) {
    print('❌ ERROR: $e');
  }
}
