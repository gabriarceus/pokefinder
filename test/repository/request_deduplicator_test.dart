import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokefinder/src/4_repository/datasources/abstract/api_client.dart';
import 'package:pokefinder/src/4_repository/services/request_deduplicator.dart';

void main() {
  late RequestDeduplicator deduplicator;

  setUp(() {
    deduplicator = RequestDeduplicator();
  });

  test('deduplicates concurrent requests for the same key', () async {
    int executionCount = 0;
    final completer = Completer<String>();

    Future<String> action() {
      executionCount++;
      return completer.future;
    }

    final future1 = deduplicator.run('endpoint', action);
    final future2 = deduplicator.run('endpoint', action);

    expect(executionCount, 1);
    expect(deduplicator.isInFlight('endpoint'), isTrue);

    completer.complete('data');

    final result1 = await future1;
    final result2 = await future2;

    expect(result1, 'data');
    expect(result2, 'data');
    expect(executionCount, 1);
    expect(deduplicator.isInFlight('endpoint'), isFalse);
  });

  test('runs separate requests for different keys', () async {
    int executionCount = 0;

    Future<String> action(String val) async {
      executionCount++;
      return val;
    }

    final result1 = await deduplicator.run('endpoint1', () => action('res1'));
    final result2 = await deduplicator.run('endpoint2', () => action('res2'));

    expect(result1, 'res1');
    expect(result2, 'res2');
    expect(executionCount, 2);
  });

  test('cleans up in-flight request when action throws', () async {
    final completer = Completer<String>();

    final future1 = deduplicator.run('key', () => completer.future);
    expect(deduplicator.isInFlight('key'), isTrue);

    completer.completeError(Exception('failed'));

    await expectLater(future1, throwsException);
    expect(deduplicator.isInFlight('key'), isFalse);
  });

  test(
    'retries action for joining caller when in-flight request is cancelled',
    () async {
      final completer1 = Completer<String>();
      final completer2 = Completer<String>();
      int executionCount = 0;

      Future<String> action() {
        executionCount++;
        return executionCount == 1 ? completer1.future : completer2.future;
      }

      final future1 = deduplicator.run('endpoint', action);
      final future2 = deduplicator.run('endpoint', action);

      expect(executionCount, 1);
      expect(deduplicator.isInFlight('endpoint'), isTrue);

      // Cancel caller 1's in-flight operation
      completer1.completeError(
        ApiException(message: 'Request was cancelled', isCancelled: true),
      );

      // Caller 1 throws cancellation
      await expectLater(
        future1,
        throwsA(
          isA<ApiException>().having(
            (e) => e.isCancelled,
            'isCancelled',
            isTrue,
          ),
        ),
      );

      // Caller 2 retries and invokes action again
      await pumpEventQueue();
      expect(executionCount, 2);

      completer2.complete('recovered');
      final result2 = await future2;

      expect(result2, 'recovered');
      expect(deduplicator.isInFlight('endpoint'), isFalse);
    },
  );

  test('supports custom isCancelled predicate', () async {
    final completer1 = Completer<String>();
    final completer2 = Completer<String>();
    int executionCount = 0;

    Future<String> action() {
      executionCount++;
      return executionCount == 1 ? completer1.future : completer2.future;
    }

    final future1 = deduplicator.run(
      'key',
      action,
      isCancelled: (e) => e is FormatException,
    );
    final future2 = deduplicator.run(
      'key',
      action,
      isCancelled: (e) => e is FormatException,
    );

    completer1.completeError(const FormatException('aborted'));

    await expectLater(future1, throwsFormatException);
    await pumpEventQueue();

    expect(executionCount, 2);
    completer2.complete('done');
    expect(await future2, 'done');
  });
}
