import 'dart:async';
import 'package:dio/dio.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'token_storage.dart';
import 'package:flutter/foundation.dart';

/// Dio interceptor that handles JWT authentication and automatic token refresh
class AuthInterceptor extends Interceptor {
  final TokenStorage _tokenStorage;
  final String _baseUrl;
  final VoidCallback? onLogout;
  
  bool _isRefreshing = false;
  Completer<void>? _refreshCompleter;

  AuthInterceptor(this._tokenStorage, this._baseUrl, {this.onLogout});

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip adding token for auth endpoints
    // Check both with and without leading slash to be safe
    final isAuthEndpoint = options.path.contains('login/') ||
        options.path.contains('register/') ||
        options.path.contains('token/refresh/') ||
        options.path.contains('password-reset/');

    if (!isAuthEndpoint) {
      // Check if the request is going to our main API base URL
      final isMainApiRequest = options.uri.toString().startsWith(_baseUrl);
      
      if (isMainApiRequest) {
        final accessToken = await _tokenStorage.getAccessToken();
        if (accessToken != null) {
          options.headers['Authorization'] = 'Bearer $accessToken';
        }
      }
    }

    // Add Sentry breadcrumb
    Sentry.addBreadcrumb(
      Breadcrumb(
        type: 'http',
        category: 'dio',
        message: 'Request: ${options.method} ${options.path}',
        data: {
          'url': options.uri.toString(),
          'method': options.method,
        },
      ),
    );

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle 401 Unauthorized - token expired
    if (err.response?.statusCode == 401 && !_isRefreshRequest(err.requestOptions)) {
      if (kDebugMode) print('🔄 [AuthInterceptor] 401 detected on ${err.requestOptions.path}, attempting token refresh...');
      
      Sentry.addBreadcrumb(
        Breadcrumb(
          message: '401 Unauthorized on ${err.requestOptions.path}, triggering refresh',
          level: SentryLevel.warning,
        ),
      );

      try {
        final refreshToken = await _tokenStorage.getRefreshToken();
        if (refreshToken == null) {
          if (kDebugMode) print('ℹ️ [AuthInterceptor] No refresh token available, clearing session.');
          await _tokenStorage.clearTokens();
          onLogout?.call();
          return handler.next(err); 
        }

        // Wait for refresh if already in progress
        await _queueRefresh();

        // Retry the original request with new token
        final accessToken = await _tokenStorage.getAccessToken();
        if (accessToken == null) throw Exception('Refresh failed to provide new token');
        
        final requestOptions = err.requestOptions;
        requestOptions.headers['Authorization'] = 'Bearer $accessToken';

        if (kDebugMode) print('🔁 [AuthInterceptor] Retrying ${err.requestOptions.path} with new token');
        
        // Use a clean Dio instance to retry to avoid recursion
        final dio = Dio(BaseOptions(
          baseUrl: _baseUrl,
          connectTimeout: const Duration(seconds: 15),
        ));
        
        final response = await dio.fetch(requestOptions);
        return handler.resolve(response);
      } catch (refreshError) {
        if (kDebugMode) print('❌ [AuthInterceptor] Token refresh failed or aborted: $refreshError');
        
        Sentry.captureException(refreshError, hint: Hint.withMap({'reason': 'Token refresh failure'}));
        
        // Refresh failed, clear tokens and let the error propagate
        await _tokenStorage.clearTokens();
        onLogout?.call();
        return handler.next(err);
      }
    }

    // Add Sentry error breadcrumb
    Sentry.addBreadcrumb(
      Breadcrumb(
        type: 'error',
        category: 'dio',
        message: 'Error: ${err.requestOptions.method} ${err.requestOptions.path}',
        level: SentryLevel.error,
        data: {
          'status_code': err.response?.statusCode,
          'error_message': err.message,
          'type': err.type.toString(),
        },
      ),
    );

    if (kDebugMode) {
      print('❌ [AuthInterceptor] Error on ${err.requestOptions.path}: ${err.response?.statusCode} ${err.message}');
    }

    handler.next(err);
  }

  /// Check if this is a token refresh request to avoid infinite loops
  bool _isRefreshRequest(RequestOptions options) {
    return options.path.contains('token/refresh/');
  }

  /// Queue token refresh to prevent multiple simultaneous refresh calls
  Future<void> _queueRefresh() async {
    if (_isRefreshing) {
      // Wait for the ongoing refresh to complete
      return _refreshCompleter!.future;
    }

    _isRefreshing = true;
    _refreshCompleter = Completer<void>();

    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken == null) {
        throw Exception('No refresh token available');
      }

      // Call the refresh endpoint
      // Partner app MUST use /partner/token/refresh/
      if (kDebugMode) print('📡 [AuthInterceptor] Calling token refresh endpoint: /partner/token/refresh/');
      final dio = Dio(BaseOptions(baseUrl: _baseUrl));
      final response = await dio.post(
        '/partner/token/refresh/',
        data: {'refresh': refreshToken},
      );

      final responseData = response.data;
      String? newAccessToken;
      
      if (responseData is Map) {
        // Adapt to possible API formats
        if (responseData['data'] != null && responseData['data']['access'] != null) {
          newAccessToken = responseData['data']['access'].toString();
        } else {
          newAccessToken = responseData['access']?.toString();
        }
      }

      if (newAccessToken == null) {
        if (kDebugMode) print('❌ [AuthInterceptor] No access token in refresh response: $responseData');
        throw Exception('No access token in refresh response');
      }

      if (kDebugMode) print('✅ [AuthInterceptor] Token refreshed successfully');
      // Save the new access token (keep the same refresh token)
      await _tokenStorage.saveTokens(
        accessToken: newAccessToken,
        refreshToken: refreshToken,
      );

      _refreshCompleter?.complete();
    } catch (e) {
      _refreshCompleter?.completeError(e);
      rethrow;
    } finally {
      _isRefreshing = false;
      _refreshCompleter = null;
    }
  }
}
