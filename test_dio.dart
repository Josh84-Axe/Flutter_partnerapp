import 'package:dio/dio.dart';

void main() {
  final dio = Dio(BaseOptions(baseUrl: 'https://staging.wifi-4u.net/v1/partner'));
  print(dio.options.baseUrl);
  
  // Create a request to see the final URI
  final req1 = RequestOptions(path: '/sessions/active/');
  print('With leading slash: ${dio.options.baseUrl}${req1.path}'); // That's not how Dio resolves it internally.
}
