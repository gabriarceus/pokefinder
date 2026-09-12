import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:pokefinder/src/4_repository/datasources/abstract/api_client.dart';

@LazySingleton(as: ApiClient)
class DioApiClient implements ApiClient {
  DioApiClient({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  @override
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Duration? timeout,
    CancelToken? cancelToken,
  }) async {
    try {
      final options = timeout != null
          ? Options(sendTimeout: timeout, receiveTimeout: timeout)
          : null;

      final response = await _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      if (response.data == null) {
        throw EmptyResponseException(path);
      }
      return response.data as T;
    } on DioException catch (e) {
      String? safeResponseBody;
      if (e.response?.data != null) {
        final bodyStr = e.response!.data.toString();
        safeResponseBody = bodyStr.length > 256
            ? '${bodyStr.substring(0, 253)}...'
            : bodyStr;
      }

      final isConnTimeout = e.type == DioExceptionType.connectionTimeout;
      final isRecvTimeout = e.type == DioExceptionType.receiveTimeout;
      final isSndTimeout = e.type == DioExceptionType.sendTimeout;
      final isConnError = e.type == DioExceptionType.connectionError;
      final isCancel = e.type == DioExceptionType.cancel;

      final message = _sanitizeErrorMessage(e);

      throw ApiException(
        message: message,
        statusCode: e.response?.statusCode,
        isConnectionTimeout: isConnTimeout,
        isReceiveTimeout: isRecvTimeout,
        isSendTimeout: isSndTimeout,
        isConnectionError: isConnError,
        isCancelled: isCancel,
        responseBody: safeResponseBody,
      );
    } catch (e) {
      if (e is ApiException ||
          e is EmptyResponseException ||
          e is TypeError ||
          e is FormatException) {
        rethrow;
      }
      throw ApiException(message: 'Unexpected network error');
    }
  }

  String _sanitizeErrorMessage(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return 'Request timed out';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'Network connection unavailable';
    }
    if (e.type == DioExceptionType.cancel) {
      return 'Request was cancelled';
    }
    if (e.response?.statusCode != null) {
      return 'HTTP ${e.response!.statusCode}';
    }
    return 'Network request failed';
  }
}
