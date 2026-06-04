/// An abstract interface for performing HTTP GET requests.
///
/// Designed to be injected into repository classes, decoupling them from
/// concrete HTTP implementations (e.g. Dio). Implementations must return
/// the decoded JSON body as a [Map<String, dynamic>].
abstract class ApiClient {
  /// Performs a GET request to the given [endpoint] and returns the
  /// response body as a decoded JSON payload.
  ///
  /// Throws an [ApiException] if the request fails, carrying the HTTP status
  /// code when one is available.
  Future<dynamic> get(String endpoint);
}

/// A transport-agnostic error raised when an [ApiClient] request fails.
///
/// Carries the HTTP [statusCode] when the failure originated from a server
/// response; transport-level errors (timeouts, connection failures) leave it
/// null. Keeps callers decoupled from any concrete HTTP implementation.
class ApiException implements Exception {
  ApiException({this.statusCode, required this.message});

  final int? statusCode;
  final String message;

  @override
  String toString() => 'ApiException($statusCode): $message';
}
