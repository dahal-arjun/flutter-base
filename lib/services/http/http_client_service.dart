import 'dart:convert';
import 'package:dio/dio.dart';

import '../../core/utils/app_logger.dart';

class HttpClientService {
  final Dio _dio;

  HttpClientService(this._dio) {
    _setupInterceptors();
  }

  /// Format JSON data for pretty printing
  String _formatJson(dynamic data) {
    try {
      if (data is String) {
        // Try to parse and format if it's a JSON string
        final decoded = jsonDecode(data);
        const encoder = JsonEncoder.withIndent('  ');
        return encoder.convert(decoded);
      } else if (data is Map || data is List) {
        // Format if it's already a Map or List
        const encoder = JsonEncoder.withIndent('  ');
        return encoder.convert(data);
      } else {
        return data.toString();
      }
    } catch (e) {
      // If it's not JSON, return as string
      return data.toString();
    }
  }

  // Setup interceptors
  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final requestInfo = <String, dynamic>{
            'method': options.method,
            'uri': options.uri.toString(),
            if (options.queryParameters.isNotEmpty)
              'query': options.queryParameters,
          };
          AppLogger.d('HTTP Request', requestInfo);
          if (options.data != null) {
            AppLogger.d('Request Body:\n${_formatJson(options.data)}');
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          final responseInfo = <String, dynamic>{
            'status': '${response.statusCode} ${response.statusMessage}',
            'method': response.requestOptions.method,
            'uri': response.requestOptions.uri.toString(),
          };
          AppLogger.i('HTTP Response', responseInfo);
          if (response.data != null) {
            AppLogger.i('Response Body:\n${_formatJson(response.data)}');
          }
          return handler.next(response);
        },
        onError: (error, handler) {
          final errorInfo = <String, dynamic>{
            'method': error.requestOptions.method,
            'uri': error.requestOptions.uri.toString(),
            if (error.response != null) ...{
              'status':
                  '${error.response?.statusCode} ${error.response?.statusMessage}',
            } else ...{
              'error': error.message,
              'type': error.type.toString(),
            },
          };

          AppLogger.e('HTTP Error', errorInfo);
          if (error.response?.data != null) {
            AppLogger.e('Error Body:\n${_formatJson(error.response?.data)}');
          }

          // Handle specific errors
          if (error.response?.statusCode == 401) {
            AppLogger.w('Unauthorized - Token may be expired');
          }

          return handler.next(error);
        },
      ),
    );
  }

  // GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  // POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  // PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  // DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  // PATCH request
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _dio.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  // Get Dio instance for advanced usage
  Dio get dio => _dio;
}
