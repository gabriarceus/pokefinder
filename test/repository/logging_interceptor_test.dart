import 'package:dio/dio.dart';
import 'package:en_logger/en_logger.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pokefinder/src/4_repository/interceptors/logging_interceptor.dart';

class _MockEnLogger extends Mock implements EnLogger {}

class _MockRequestInterceptorHandler extends Mock
    implements RequestInterceptorHandler {}

class _MockResponseInterceptorHandler extends Mock
    implements ResponseInterceptorHandler {}

class _MockErrorInterceptorHandler extends Mock
    implements ErrorInterceptorHandler {}

void main() {
  late _MockEnLogger logger;
  late LoggingInterceptor interceptor;

  setUp(() {
    logger = _MockEnLogger();
    interceptor = LoggingInterceptor(logger: logger, verbose: true);
  });

  group('LoggingInterceptor', () {
    test('logs request details on onRequest', () {
      final options = RequestOptions(
        path: '/pokemon/pikachu',
        method: 'GET',
        headers: {'Accept': 'application/json'},
        data: {'query': 'pikachu'},
      );
      final handler = _MockRequestInterceptorHandler();

      interceptor.onRequest(options, handler);

      verify(() => logger.info(any(), prefix: 'HTTP')).called(1);
      verify(() => logger.debug(any(), prefix: 'HTTP')).called(2);
      verify(() => handler.next(options)).called(1);
    });

    test('logs response status on onResponse', () {
      final options = RequestOptions(path: '/pokemon/pikachu', method: 'GET');
      final handler = _MockRequestInterceptorHandler();
      interceptor.onRequest(options, handler);

      final response = Response<dynamic>(
        requestOptions: options,
        statusCode: 200,
        data: {'name': 'pikachu'},
      );
      final responseHandler = _MockResponseInterceptorHandler();

      interceptor.onResponse(response, responseHandler);

      verify(
        () => logger.info(any(that: contains('200 GET')), prefix: 'HTTP'),
      ).called(1);
      verify(() => responseHandler.next(response)).called(1);
    });

    test('logs error details on onError', () {
      final options = RequestOptions(path: '/pokemon/unknown', method: 'GET');
      final handler = _MockRequestInterceptorHandler();
      interceptor.onRequest(options, handler);

      final err = DioException(
        requestOptions: options,
        response: Response(
          requestOptions: options,
          statusCode: 404,
          data: 'Not found',
        ),
        message: 'Resource not found',
      );
      final errorHandler = _MockErrorInterceptorHandler();

      interceptor.onError(err, errorHandler);

      verify(
        () => logger.error(any(that: contains('404 GET')), prefix: 'HTTP'),
      ).called(1);
      verify(() => errorHandler.next(err)).called(1);
    });

    test('non-verbose mode logs summary without headers or body', () {
      final quietInterceptor = LoggingInterceptor(
        logger: logger,
        verbose: false,
      );
      final options = RequestOptions(
        path: '/test',
        headers: {'Secret': 'value'},
        data: 'body',
      );
      final reqHandler = _MockRequestInterceptorHandler();

      quietInterceptor.onRequest(options, reqHandler);

      verify(() => logger.info(any(), prefix: 'HTTP')).called(1);
      verifyNever(() => logger.debug(any(), prefix: 'HTTP'));
      verify(() => reqHandler.next(options)).called(1);
    });
  });
}
