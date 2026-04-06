import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Interceptor that retries requests on network failures
class ApiRetryInterceptor extends Interceptor {
  final int maxRetries;
  final Duration retryInterval;

  ApiRetryInterceptor({
    this.maxRetries = 3,
    this.retryInterval = const Duration(seconds: 2),
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Only retry on network issues or timeouts
    if (_shouldRetry(err)) {
      int retryCount = 0;
      
      // Check if this request has already been retried
      if (err.requestOptions.extra.containsKey('retry_count')) {
        retryCount = err.requestOptions.extra['retry_count'] as int;
      }

      if (retryCount < maxRetries) {
        retryCount++;
        
        if (kDebugMode) {
          print('📡 [RetryInterceptor] Retrying ${err.requestOptions.path} ($retryCount/$maxRetries) due to ${err.type}');
        }

        // Delay before retrying (exponential backoff)
        final delay = retryInterval * retryCount;
        await Future.delayed(delay);

        try {
          // Update retry count in extra
          err.requestOptions.extra['retry_count'] = retryCount;
          
          // Re-send the request
          final dio = Dio(err.requestOptions.toBaseOptions());
          final response = await dio.fetch(err.requestOptions);
          
          return handler.resolve(response);
        } catch (e) {
          // If retry fails, we let it propagate or try again if count < maxRetries
          // In this simple implementation, we just pass the new error
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

extension RequestOptionsExtensions on RequestOptions {
  BaseOptions toBaseOptions() {
    return BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      sendTimeout: sendTimeout,
      headers: headers,
      responseType: responseType,
      contentType: contentType,
      validateStatus: validateStatus,
      receiveDataWhenStatusError: receiveDataWhenStatusError,
      extra: extra,
    );
  }
}
