import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Interceptor that retries requests on network failures.
/// IMPORTANT: Must be initialized with a reference to the parent [Dio] instance
/// so that retries go through all other interceptors (auth, logging, etc.).
class ApiRetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;
  final Duration retryInterval;

  ApiRetryInterceptor({
    required this.dio,
    this.maxRetries = 3,
    this.retryInterval = const Duration(seconds: 2),
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Only retry on network issues or timeouts (not on 4xx/5xx)
    if (_shouldRetry(err)) {
      int retryCount = 0;

      // Check if this request has already been retried
      if (err.requestOptions.extra.containsKey('retry_count')) {
        retryCount = err.requestOptions.extra['retry_count'] as int;
      }

      if (retryCount < maxRetries) {
        retryCount++;

        if (kDebugMode) {
          debugPrint(
            '📡 [RetryInterceptor] Retrying ${err.requestOptions.path} '
            '($retryCount/$maxRetries) due to ${err.type}',
          );
        }

        // Exponential backoff
        final delay = retryInterval * retryCount;
        await Future.delayed(delay);

        try {
          // Update retry count in extra so we don't loop forever
          err.requestOptions.extra['retry_count'] = retryCount;

          // Use the PARENT Dio so all interceptors (auth, logging) are preserved.
          final response = await dio.fetch(err.requestOptions);
          return handler.resolve(response);
        } catch (e) {
          if (e is DioException) {
            return super.onError(e, handler);
          }
        }
      }
    }

    super.onError(err, handler);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.connectionError;
  }
}


