import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:pokefinder/src/4_repository/datasources/abstract/api_client.dart';

/// Concrete [ApiClient] backed by [Dio].
///
/// Delegates HTTP GET requests to a [Dio] instance and extracts the
/// response body as a [Map<String, dynamic>]. Translates any [DioException]
/// into a transport-agnostic [ApiException] so callers stay decoupled from Dio.
@LazySingleton(as: ApiClient)
class DioApiClient implements ApiClient {
  DioApiClient({required Dio dio}) : _dio = dio;

  final Dio _dio;

  @override
  Future<dynamic> get(String endpoint) async {
    try {
      final response = await _dio.get<dynamic>(endpoint);
      final data = response.data;
      if (data == null) {
        throw EmptyResponseException(endpoint);
      }
      return data;
    } on DioException catch (e) {
      throw ApiException(
        statusCode: e.response?.statusCode,
        message: e.message ?? e.toString(),
      );
    }
  }
}

/// Thrown when a successful HTTP response carries no body.
class EmptyResponseException implements Exception {
  EmptyResponseException(this.endpoint);

  /// The endpoint whose response was empty.
  final String endpoint;

  @override
  String toString() => 'EmptyResponseException: no body returned for $endpoint';
}
