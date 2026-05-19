import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:pokefinder/src/4_repository/datasources/abstract/api_client.dart';

/// Concrete [ApiClient] backed by [Dio].
///
/// Delegates HTTP GET requests to a [Dio] instance and extracts the
/// response body as a [Map<String, dynamic>]. Any [DioException] or
/// unexpected error is rethrown to be handled by the caller.
@LazySingleton(as: ApiClient)
class DioApiClient implements ApiClient {
  DioApiClient({required Dio dio}) : _dio = dio;

  final Dio _dio;

  @override
  Future<Map<String, dynamic>> get(String endpoint) async {
    final response = await _dio.get<Map<String, dynamic>>(endpoint);
    return response.data!;
  }
}
