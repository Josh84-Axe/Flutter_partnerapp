
import 'package:dio/dio.dart';

void main() async {
  final dio = Dio();
  const baseUrl = 'https://api.coleah.com/api/cases/external/cases/';
  const apiKey = 'aPuOwuzgw2HWPiWuVM5AcwexsVNiKKJkqEWXFHN2nHE';
  const email = 'josh@tiknetafrica.com'; // Use a known user email if possible

  print('--- Testing Ticket Listing ---');
  try {
    final response = await dio.get(
      baseUrl,
      options: Options(
        headers: {
          'X-Api-Key': apiKey,
        },
      ),
      queryParameters: {
        'contact_email': email,
      },
    );
    print('Status Code: ${response.statusCode}');
    print('Data: ${response.data}');
  } catch (e) {
    if (e is DioException) {
      print('Status Code: ${e.response?.statusCode}');
      print('Error Data: ${e.response?.data}');
    } else {
      print('Error: $e');
    }
  }

  print('\n--- Testing Ticket Listing with "email" parameter ---');
  try {
    final response = await dio.get(
      baseUrl,
      options: Options(
        headers: {
          'X-Api-Key': apiKey,
        },
      ),
      queryParameters: {
        'email': email,
      },
    );
    print('Status Code: ${response.statusCode}');
    print('Data: ${response.data}');
  } catch (e) {
    if (e is DioException) {
      print('Status Code: ${e.response?.statusCode}');
      print('Error Data: ${e.response?.data}');
    } else {
      print('Error: $e');
    }
  }
}
