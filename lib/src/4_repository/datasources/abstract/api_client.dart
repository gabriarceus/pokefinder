/// An abstract interface for performing HTTP GET requests.
///
/// Designed to be injected into repository classes, decoupling them from
/// concrete HTTP implementations (e.g. Dio). Implementations must return
/// the decoded JSON body as a [Map<String, dynamic>].
abstract class ApiClient {
  /// Performs a GET request to the given [endpoint] and returns the
  /// response body as a decoded JSON payload.
  ///
  /// Throws an exception if the request fails.
  Future<dynamic> get(String endpoint);
}
