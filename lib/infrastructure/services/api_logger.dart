import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Interceptor de logging para requests HTTP.
/// Muestra method/url, query, body, status y respuesta.
class ApiLoggerInterceptor extends Interceptor {
  ApiLoggerInterceptor({required this.enabled});

  final bool enabled;
  static const int _maxLen = 1200;

  bool get _isActive => enabled && kDebugMode;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_isActive) {
      final payload = _truncate(_toPretty(options.data));
      debugPrint(
        '[API][REQ] ${options.method} ${options.baseUrl}${options.path} '
        'query=${options.queryParameters}',
      );
      if (payload.isNotEmpty) debugPrint('[API][REQ][BODY] $payload');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (_isActive) {
      final payload = _truncate(_toPretty(response.data));
      debugPrint(
        '[API][RES] ${response.requestOptions.method} '
        '${response.requestOptions.path} status=${response.statusCode}',
      );
      if (payload.isNotEmpty) debugPrint('[API][RES][BODY] $payload');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (_isActive) {
      final payload = _truncate(_toPretty(err.response?.data));
      debugPrint(
        '[API][ERR] ${err.requestOptions.method} ${err.requestOptions.path} '
        'status=${err.response?.statusCode} message=${err.message}',
      );
      if (payload.isNotEmpty) debugPrint('[API][ERR][BODY] $payload');
    }
    handler.next(err);
  }

  String _toPretty(dynamic data) {
    if (data == null) return '';
    if (data is String) return data;
    try {
      return const JsonEncoder.withIndent('  ').convert(data);
    } catch (_) {
      return data.toString();
    }
  }

  String _truncate(String value) {
    if (value.length <= _maxLen) return value;
    return '${value.substring(0, _maxLen)} ...[truncated]';
  }
}
