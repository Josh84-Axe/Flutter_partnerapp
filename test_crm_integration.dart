
import 'package:dio/dio.dart';

void main() async {
  final dio = Dio();
  const String baseUrl = 'https://api.coleah.com/api/cases/external/cases/';
  const String apiKey = 'QNBBRFCO0rfnxFxS9buqx2cMjTbDwQEd3Zwhew_TXMI';

  print('🚀 Sending ALIGNED test ticket to Coleah CRM...');

  try {
    final response = await dio.post(
      baseUrl,
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'X-Api-Key': apiKey,
        },
        validateStatus: (status) => true,
      ),
      data: {
        'subject': 'Aligned Payload Test - Tiknet',
        'description': 'Verifying the new payload structure with metadata and contact phone. [Diagnostic Timestamp: ${DateTime.now().toIso8601String()}]',
        'contact_name': 'Tiknet Developer Assistant',
        'contact_email': 'assistant@tiknetafrica.com',
        'contact_phone': '+22890000000',
        'country': 'TG',
        'priority': 'MEDIUM',
        'metadata': {
          'origin': 'partner_app'
        }
      },
    );

    print('\n📡 Backend Response:');
    print('Status Code: ${response.statusCode}');
    print('Body: ${response.data}');
  } catch (e) {
    print('\n❌ Request Failed:');
    print(e.toString());
  }
}
