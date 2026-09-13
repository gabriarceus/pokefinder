import 'dart:async';

import 'package:en_logger/en_logger.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pokefinder/src/3_domain/services/cry_audio_controller.dart';
import 'package:pokefinder/src/4_repository/services/cry_audio_controller_impl.dart';

class _MockEnLogger extends Mock implements EnLogger {}

class _MockAudioPlayer extends Mock implements AudioPlayer {}

class _FakeAudioSource extends Fake implements AudioSource {}

void main() {
  late _MockEnLogger logger;
  late _MockAudioPlayer player;
  late StreamController<PlaybackEvent> playbackEventController;
  late StreamController<PlayerState> playerStateController;
  late JustAudioCryController controller;

  setUpAll(() {
    registerFallbackValue(_FakeAudioSource());
    registerFallbackValue(Duration.zero);
  });

  setUp(() {
    logger = _MockEnLogger();
    player = _MockAudioPlayer();
    playbackEventController = StreamController<PlaybackEvent>.broadcast();
    playerStateController = StreamController<PlayerState>.broadcast();

    when(
      () => player.playbackEventStream,
    ).thenAnswer((_) => playbackEventController.stream);
    when(
      () => player.playerStateStream,
    ).thenAnswer((_) => playerStateController.stream);
    when(
      () => player.playerState,
    ).thenReturn(PlayerState(false, ProcessingState.idle));
    when(() => player.processingState).thenReturn(ProcessingState.idle);
    when(() => player.stop()).thenAnswer((_) async {});
    when(() => player.seek(any())).thenAnswer((_) async {});
    when(() => player.play()).thenAnswer((_) async {});
    when(() => player.setVolume(any())).thenAnswer((_) async {});
    when(() => player.dispose()).thenAnswer((_) async {});

    controller = JustAudioCryController.withPlayer(logger, player);
  });

  tearDown(() async {
    await playbackEventController.close();
    await playerStateController.close();
  });

  group('JustAudioCryController', () {
    const testUrl = 'https://example.com/cry.ogg';

    test('initial state defaults correctly', () {
      expect(controller.state, const CryPlaybackState());
      expect(controller.state.unavailable, isFalse);
      expect(controller.state.playing, isFalse);
      expect(controller.state.loading, isFalse);
    });

    test('load failure emits unavailable state and does not play', () async {
      when(
        () => player.setAudioSource(any(), preload: any(named: 'preload')),
      ).thenThrow(Exception('Network error'));

      final emittedStates = <CryPlaybackState>[];
      final subscription = controller.stateStream.listen(emittedStates.add);

      await controller.toggle(testUrl);
      await pumpEventQueue();

      expect(controller.state.unavailable, isTrue);
      expect(controller.state.loading, isFalse);
      expect(controller.state.playing, isFalse);
      expect(controller.state.currentUrl, testUrl);
      verifyNever(() => player.play());

      // Should have emitted loading state then unavailable state
      expect(emittedStates.any((s) => s.loading && !s.unavailable), isTrue);
      expect(emittedStates.any((s) => !s.loading && s.unavailable), isTrue);

      await subscription.cancel();
    });

    test('retry after load failure succeeds and invokes play', () async {
      // First attempt fails
      when(
        () => player.setAudioSource(any(), preload: any(named: 'preload')),
      ).thenThrow(Exception('Network error'));

      await controller.toggle(testUrl);
      expect(controller.state.unavailable, isTrue);

      // Retry attempt succeeds
      when(
        () => player.setAudioSource(any(), preload: any(named: 'preload')),
      ).thenAnswer((_) async => const Duration(seconds: 1));

      await controller.toggle(testUrl);

      expect(controller.state.unavailable, isFalse);
      expect(controller.state.loading, isFalse);
      verify(() => player.play()).called(1);
    });

    test('playback stream error marks controller as unavailable', () async {
      final emittedStates = <CryPlaybackState>[];
      final subscription = controller.stateStream.listen(emittedStates.add);

      playbackEventController.addError(Exception('Playback decode error'));
      await pumpEventQueue();

      expect(controller.state.unavailable, isTrue);
      expect(emittedStates.any((s) => s.unavailable), isTrue);

      await subscription.cancel();
    });

    test('toggle stops playback if currently playing the same url', () async {
      // First, successful load
      when(
        () => player.setAudioSource(any(), preload: any(named: 'preload')),
      ).thenAnswer((_) async => const Duration(seconds: 1));

      await controller.toggle(testUrl);
      verify(() => player.play()).called(1);

      // Simulate player state transitioning to playing
      when(
        () => player.playerState,
      ).thenReturn(PlayerState(true, ProcessingState.ready));

      // Toggle again
      await controller.toggle(testUrl);

      verify(() => player.stop()).called(1);
    });

    test('toggle seeks to start and replays when completed', () async {
      // First, successful load
      when(
        () => player.setAudioSource(any(), preload: any(named: 'preload')),
      ).thenAnswer((_) async => const Duration(seconds: 1));

      await controller.toggle(testUrl);

      // Simulate completed playback
      when(
        () => player.playerState,
      ).thenReturn(PlayerState(false, ProcessingState.completed));

      await controller.toggle(testUrl);

      verify(() => player.seek(Duration.zero)).called(1);
      verify(() => player.play()).called(2);
    });

    test('stops active player before loading new audio source', () async {
      when(() => player.processingState).thenReturn(ProcessingState.ready);
      when(
        () => player.setAudioSource(any(), preload: any(named: 'preload')),
      ).thenAnswer((_) async => const Duration(seconds: 1));

      await controller.toggle(testUrl);

      verify(() => player.stop()).called(1);
      verify(() => player.setAudioSource(any(), preload: true)).called(1);
    });

    test('setVolume clamps volume and delegates to player', () async {
      await controller.setVolume(0.8);
      verify(() => player.setVolume(0.8)).called(1);

      await controller.setVolume(1.5);
      verify(() => player.setVolume(1.0)).called(1);

      await controller.setVolume(-0.5);
      verify(() => player.setVolume(0.0)).called(1);
    });

    test('play re-plays current url from start without reloading', () async {
      when(
        () => player.setAudioSource(any(), preload: any(named: 'preload')),
      ).thenAnswer((_) async => const Duration(seconds: 1));

      await controller.play(testUrl);
      verify(() => player.play()).called(1);

      // Play same url again -> seeks to zero and plays
      await controller.play(testUrl);
      verify(() => player.seek(Duration.zero)).called(1);
      verify(() => player.play()).called(1);
    });

    test(
      'dispose cancels subscriptions, closes stream, and disposes player',
      () async {
        await controller.dispose();

        verify(() => player.dispose()).called(1);
        expect(controller.stateStream, emitsDone);
      },
    );
  });
}
