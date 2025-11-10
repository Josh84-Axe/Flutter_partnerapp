import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'auth_interceptor.dart';
import 'token_storage.dart';

/// Factory for creating configured API clients with authentication
class ApiClientFactory {
  final TokenStorage _tokenStorage;
  final String _baseUrl;

  ApiClientFactory({
    required TokenStorage tokenStorage,
    String? baseUrl,
  })  : _tokenStorage = tokenStorage,
        _baseUrl = baseUrl ?? 'https://api.tiknetafrica.com/v1';

  /// Create a configured Dio instance with auth interceptors
  Dio createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add pretty logger in debug mode only
    if (!kReleaseMode) {
      dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: false,
          responseHeader: false,
          error: true,
          compact: true,
          maxWidth: 90,
          // Don't log Authorization headers for security
          filter: (options, args) {
            if (options.headers.containsKey('Authorization')) {
              options.headers['Authorization'] = 'Bearer [REDACTED]';
            }
            return true;
          },
        ),
      );
    }

    // Add auth interceptor for automatic token management
    dio.interceptors.add(AuthInterceptor(_tokenStorage, _baseUrl));

    return dio;
  }
}
