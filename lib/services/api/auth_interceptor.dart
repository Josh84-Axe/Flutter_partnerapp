import 'dart:async';
import 'package:dio/dio.dart';
import 'token_storage.dart';

/// Dio interceptor that handles JWT authentication and automatic token refresh
class AuthInterceptor extends Interceptor {
  final TokenStorage _tokenStorage;
  final String _baseUrl;
  
  bool _isRefreshing = false;
  Completer<void>? _refreshCompleter;

  AuthInterceptor(this._tokenStorage, this._baseUrl);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip adding token for auth endpoints
    final isAuthEndpoint = options.path.contains('/login/') ||
        options.path.contains('/register/') ||
        options.path.contains('/token/refresh/');

    if (!isAuthEndpoint) {
      final accessToken = await _tokenStorage.getAccessToken();
      if (accessToken != null) {
        options.headers['Authorization'] = 'Bearer $accessToken';
      }
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle 401 Unauthorized - token expired
    if (err.response?.statusCode == 401 && !_isRefreshRequest(err.requestOptions)) {
      try {
        // Wait for refresh if already in progress
        await _queueRefresh();

        // Retry the original request with new token
        final accessToken = await _tokenStorage.getAccessToken();
        final requestOptions = err.requestOptions;
        requestOptions.headers['Authorization'] = 'Bearer $accessToken';

        // Create a new Dio instance to avoid interceptor loops
        final dio = Dio(BaseOptions(baseUrl: _baseUrl));
        final response = await dio.fetch(requestOptions);
        
        return handler.resolve(response);
      } catch (refreshError) {
        // Refresh failed, clear tokens and let the error propagate
        await _tokenStorage.clearTokens();
        return handler.reject(err);
      }
    }

    handler.next(err);
  }

  /// Check if this is a token refresh request to avoid infinite loops
  bool _isRefreshRequest(RequestOptions options) {
    return options.path.contains('/token/refresh/');
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
      // Note: Using /customer/token/refresh/ as per API spec
      // TODO: Verify if partner uses same endpoint or has separate /partner/token/refresh/
      final dio = Dio(BaseOptions(baseUrl: _baseUrl));
      final response = await dio.post(
        '/customer/token/refresh/',
        data: {'refresh': refreshToken},
      );

      final newAccessToken = response.data['access'] as String?;
      if (newAccessToken == null) {
        throw Exception('No access token in refresh response');
      }

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
