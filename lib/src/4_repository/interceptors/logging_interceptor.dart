import 'package:dio/dio.dart';
import 'package:en_logger/en_logger.dart';

const _prefix = 'HTTP';

/// A Dio [Interceptor] that logs HTTP requests and responses using [EnLogger].
///
/// In normal mode, logs:
/// - Request method and URL
/// - Response status code with elapsed time
///
/// In verbose mode (`verbose: true`), additionally logs:
/// - Request headers and body (payload sent)
/// - Response body (payload received)
class LoggingInterceptor extends Interceptor {
  LoggingInterceptor({
    required EnLogger logger,
    this.verbose = false,
  }) : _logger = logger;

  final EnLogger _logger;

  /// When true, request/response bodies are also logged.
  final bool verbose;

  /// Stores the request start time to calculate elapsed duration.
  final Map<RequestOptions, DateTime> _startTimes = {};

  /// Entries older than this are pruned defensively, in case a request never
  /// reaches onResponse/onError (e.g. cancellation), to keep the map bounded.
  static const _staleThreshold = Duration(minutes: 5);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _pruneStaleEntries();
    _startTimes[options] = DateTime.now();

    _logger.info(
      '→ ${options.method} ${options.uri}',
      prefix: _prefix,
    );

    if (verbose) {
      if (options.headers.isNotEmpty) {
        _logger.debug('  Headers: ${options.headers}', prefix: _prefix);
      }
      if (options.data != null) {
        _logger.debug('  Body: ${options.data}', prefix: _prefix);
      }
    }

    handler.next(options);
  }

  @override
  void onResponse(
      Response<dynamic> response, ResponseInterceptorHandler handler) {
    final elapsed = _elapsedFor(response.requestOptions);

    _logger.info(
      '← ${response.statusCode} ${response.requestOptions.method} '
      '${response.requestOptions.uri} ($elapsed)',
      prefix: _prefix,
    );

    if (verbose) {
      final body = response.data?.toString() ?? '';
      _logger.debug('  Response: $body', prefix: _prefix);
    }

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final elapsed = _elapsedFor(err.requestOptions);
    final statusCode = err.response?.statusCode ?? 'N/A';

    _logger.error(
      '✗ $statusCode ${err.requestOptions.method} '
      '${err.requestOptions.uri} ($elapsed) — ${err.message}',
      prefix: _prefix,
    );

    if (verbose && err.response?.data != null) {
      final body = err.response!.data.toString();
      _logger.debug('  Error body: $body', prefix: _prefix);
    }

    handler.next(err);
  }

  /// Returns a human-readable elapsed time string for the given request.
  String _elapsedFor(RequestOptions options) {
    final start = _startTimes.remove(options);
    if (start == null) return '?ms';
    final ms = DateTime.now().difference(start).inMilliseconds;
    return '${ms}ms';
  }

  /// Drops timing entries older than [_staleThreshold] so [_startTimes] stays
  /// bounded even when a request never completes.
  void _pruneStaleEntries() {
    final now = DateTime.now();
    _startTimes
        .removeWhere((_, start) => now.difference(start) > _staleThreshold);
  }
}
