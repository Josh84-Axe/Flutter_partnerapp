import 'package:dio/dio.dart';

void main() {
  final dio = Dio(BaseOptions(baseUrl: 'https://staging.wifi-4u.net/v1/partner'));
  final req1 = '${dio.options.baseUrl}/login/';
  // Dio merges by:
  // if path starts with http, it uses it.
  // if not, it joins baseUrl and path.
  // Let's see how dio merges it by checking RequestOptions:
  final options = RequestOptions(path: '/login/', baseUrl: 'https://staging.wifi-4u.net/v1/partner');
  print('Dio merged /login/: ${options.uri}');
  
  final options2 = RequestOptions(path: 'login/', baseUrl: 'https://staging.wifi-4u.net/v1/partner/');
  print('Dio merged login/: ${options2.uri}');
}
