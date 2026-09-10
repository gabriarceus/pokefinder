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

/// Raised when an API client returns an empty or null body.
class EmptyResponseException implements Exception {
  EmptyResponseException(this.endpoint);
  final String endpoint;

  @override
  String toString() => 'EmptyResponseException: no body returned for $endpoint';
}

/// A transport-agnostic error raised when an [ApiClient] request fails.
///
/// Preserves transport diagnostics including [statusCode], timeout flags,
/// cancellation status, connection errors, and safe truncated [responseBody].
class ApiException implements Exception {
  ApiException({
    this.statusCode,
    required this.message,
    this.isConnectionTimeout = false,
    this.isReceiveTimeout = false,
    this.isSendTimeout = false,
    this.isCancelled = false,
    this.isConnectionError = false,
    this.responseBody,
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

  /// True if the request was cancelled before completion.
  final bool isCancelled;

  /// True if there was a low-level network/socket connectivity failure.
  final bool isConnectionError;

  /// Safely truncated response body received from the remote server, if any.
  final String? responseBody;

  /// True if any timeout occurred during the request.
  bool get isTimeout =>
      isConnectionTimeout || isReceiveTimeout || isSendTimeout;

  @override
  String toString() =>
      'ApiException(statusCode: $statusCode, isTimeout: $isTimeout, '
      'isConnectionError: $isConnectionError, isCancelled: $isCancelled): $message';
}
