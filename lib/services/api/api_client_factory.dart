import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'auth_interceptor.dart';
import 'logging_interceptor.dart';
import 'token_storage.dart';

/// Factory for creating configured API clients with authentication
class ApiClientFactory {
  final TokenStorage _tokenStorage;
  final String _baseUrl;

  ApiClientFactory({
    required TokenStorage tokenStorage,
    String? baseUrl,
  })  : _tokenStorage = tokenStorage,
        _baseUrl = baseUrl ?? 'https://api.tiknetafrica.com/v1' {
    // Print BASE_URL at initialization for debugging
    if (kDebugMode) {
      print('');
      print('═══════════════════════════════════════════════════════════');
      print('🌐 API CLIENT FACTORY INITIALIZED');
      print('═══════════════════════════════════════════════════════════');
      print('BASE_URL: $_baseUrl');
      print('═══════════════════════════════════════════════════════════');
      print('');
    }
  }

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

    // Add comprehensive logging interceptor in debug mode
    if (kDebugMode) {
      dio.interceptors.add(ApiLoggingInterceptor());
    }

    // Add auth interceptor for automatic token management
    dio.interceptors.add(AuthInterceptor(_tokenStorage, _baseUrl));

    return dio;
  }
}
