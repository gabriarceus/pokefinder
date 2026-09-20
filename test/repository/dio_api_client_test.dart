import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pokefinder/src/4_repository/datasources/abstract/api_client.dart';
import 'package:pokefinder/src/4_repository/datasources/implementations/dio_api_client.dart';

class _MockDio extends Mock implements Dio {}

void main() {
  late _MockDio dio;
  late DioApiClient client;

  setUp(() {
    dio = _MockDio();
    client = DioApiClient(dio: dio);
  });

  group('DioApiClient error mapping', () {
    final requestOptions = RequestOptions(path: '/pokemon/test');

    test('maps connection timeout', () async {
      when(() => dio.get<dynamic>(any())).thenThrow(
        DioException(
          requestOptions: requestOptions,
          type: DioExceptionType.connectionTimeout,
          message: 'connect timeout',
        ),
      );

      expect(
        () => client.get('/pokemon/test'),
        throwsA(
          isA<ApiException>()
              .having(
                (e) => e.isConnectionTimeout,
                'isConnectionTimeout',
                isTrue,
              )
              .having((e) => e.isTimeout, 'isTimeout', isTrue),
        ),
      );
    });

    test('maps receive timeout', () async {
      when(() => dio.get<dynamic>(any())).thenThrow(
        DioException(
          requestOptions: requestOptions,
          type: DioExceptionType.receiveTimeout,
          message: 'receive timeout',
        ),
      );

      expect(
        () => client.get('/pokemon/test'),
        throwsA(
          isA<ApiException>()
              .having((e) => e.isReceiveTimeout, 'isReceiveTimeout', isTrue)
              .having((e) => e.isTimeout, 'isTimeout', isTrue),
        ),
      );
    });

    test('maps connection error', () async {
      when(() => dio.get<dynamic>(any())).thenThrow(
        DioException(
          requestOptions: requestOptions,
          type: DioExceptionType.connectionError,
          message: 'Failed host lookup',
        ),
      );

      expect(
        () => client.get('/pokemon/test'),
        throwsA(
          isA<ApiException>().having(
            (e) => e.isConnectionError,
            'isConnectionError',
            isTrue,
          ),
        ),
      );
    });

    test('maps cancel', () async {
      when(() => dio.get<dynamic>(any())).thenThrow(
        DioException(
          requestOptions: requestOptions,
          type: DioExceptionType.cancel,
          message: 'request cancelled',
        ),
      );

      expect(
        () => client.get('/pokemon/test'),
        throwsA(
          isA<ApiException>().having(
            (e) => e.isCancelled,
            'isCancelled',
            isTrue,
          ),
        ),
      );
    });

    test('maps status code and safely truncates response body', () async {
      final longBody = 'A' * 500;
      when(() => dio.get<dynamic>(any())).thenThrow(
        DioException(
          requestOptions: requestOptions,
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: requestOptions,
            statusCode: 404,
            data: longBody,
          ),
        ),
      );

      expect(
        () => client.get('/pokemon/test'),
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 404)
              .having(
                (e) => e.responseBody?.length,
                'responseBody length',
                256,
              ),
        ),
      );
    });

    test(
      'maps unexpected non-Dio exceptions without leaking details',
      () async {
        when(
          () => dio.get<dynamic>(any()),
        ).thenThrow(Exception('sensitive internal error'));

        expect(
          () => client.get('/pokemon/test'),
          throwsA(
            isA<ApiException>().having(
              (e) => e.message,
              'message',
              'Unexpected network error',
            ),
          ),
        );
      },
    );

    test('allows TypeError from type cast to propagate', () async {
      when(() => dio.get<dynamic>(any())).thenAnswer(
        (_) async => Response(
          requestOptions: requestOptions,
          data: 'a string, not a map',
        ),
      );

      expect(
        () => client.get<Map<String, dynamic>>('/pokemon/test'),
        throwsA(isA<TypeError>()),
      );
    });

    test('allows FormatException to propagate', () async {
      when(
        () => dio.get<dynamic>(any()),
      ).thenThrow(const FormatException('malformed data'));

      expect(
        () => client.get('/pokemon/test'),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
