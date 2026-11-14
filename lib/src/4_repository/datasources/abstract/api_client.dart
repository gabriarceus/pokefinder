/// An abstract interface for performing HTTP GET requests.
///
/// Designed to be injected into repository classes, decoupling them from
/// concrete HTTP implementations (e.g. Dio). Implementations must return
/// the decoded JSON body as [T].
abstract class ApiClient {
  /// Performs a GET request to the given [endpoint] and returns the
  /// response body as a decoded JSON payload.
  ///
  /// Throws an [ApiException] if the request fails, carrying the HTTP status
  /// code when one is available.
  Future<T> get<T>(String endpoint);
}

/// Raised when an API client returns an empty or null body.
class EmptyResponseException implements Exception {
  EmptyResponseException(this.endpoint);
  final String endpoint;

  @override
  String toString() => 'EmptyResponseException: no body returned for $endpoint';
}

/// A transport-agnostic error raised when an [ApiClient] request fails.
///
/// Preserves transport diagnostics including [statusCode], timeout flags and
/// connection errors.
class ApiException implements Exception {
  ApiException({
    this.statusCode,
    required this.message,
    this.isConnectionTimeout = false,
    this.isReceiveTimeout = false,
    this.isSendTimeout = false,
    this.isConnectionError = false,
  });

  /// HTTP status code returned by the server, or null for transport errors.
  final int? statusCode;

  /// Diagnostic failure description.
  final String message;

  /// True if the connection could not be established before the timeout.
  final bool isConnectionTimeout;

  /// True if receiving data exceeded the timeout duration.
  final bool isReceiveTimeout;

  /// True if sending data exceeded the timeout duration.
  final bool isSendTimeout;

  /// True if there was a low-level network/socket connectivity failure.
  final bool isConnectionError;

  /// True if any timeout occurred during the request.
  bool get isTimeout =>
      isConnectionTimeout || isReceiveTimeout || isSendTimeout;

  @override
  String toString() =>
      'ApiException(statusCode: $statusCode, isTimeout: $isTimeout, '
      'isConnectionError: $isConnectionError): $message';
}
