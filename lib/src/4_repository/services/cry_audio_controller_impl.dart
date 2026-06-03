import 'dart:async';

import 'package:en_logger/en_logger.dart';
import 'package:injectable/injectable.dart';
import 'package:just_audio/just_audio.dart';
import 'package:pokefinder/src/3_domain/services/cry_audio_controller.dart';

/// [CryAudioController] backed by a [just_audio] [AudioPlayer].
///
/// Each instance owns its own player and subscriptions; resolve a fresh
/// instance per screen and call [dispose] when done.
@Injectable(as: CryAudioController)
class JustAudioCryController implements CryAudioController {
  JustAudioCryController(this._logger) {
    _playbackSubscription = _player.playbackEventStream.listen(
      (event) {
        _logger.info("Playback event: ${event.processingState}",
            prefix: _prefix);
      },
      onError: (Object e, StackTrace stacktrace) {
        _logger.error("Playback error: $e", prefix: _prefix);
      },
    );
    _playerStateSubscription = _player.playerStateStream.listen((_) => _emit());
  }

  static const _prefix = 'CryAudioController';

  final EnLogger _logger;
  final AudioPlayer _player = AudioPlayer();
  final StreamController<CryPlaybackState> _controller =
      StreamController<CryPlaybackState>.broadcast();

  late final StreamSubscription<PlaybackEvent> _playbackSubscription;
  late final StreamSubscription<PlayerState> _playerStateSubscription;

  String? _currentUrl;
  bool _loading = false;
  CryPlaybackState _last = const CryPlaybackState();

  @override
  Stream<CryPlaybackState> get stateStream => _controller.stream;

  @override
  CryPlaybackState get state => _snapshot();

  CryPlaybackState _snapshot() {
    final playerState = _player.playerState;
    return CryPlaybackState(
      currentUrl: _currentUrl,
      playing: playerState.playing,
      completed: playerState.processingState == ProcessingState.completed,
      loading: _loading,
    );
  }

  void _emit() {
    if (_controller.isClosed) return;
    final next = _snapshot();
    if (next == _last) return;
    _last = next;
    _controller.add(next);
  }

  @override
  Future<void> toggle(String url) async {
    final playerState = _player.playerState;
    final isCurrent = _currentUrl == url;

    if (isCurrent &&
        playerState.playing &&
        playerState.processingState != ProcessingState.completed) {
      await _player.stop();
      return;
    }

    if (isCurrent && playerState.processingState == ProcessingState.completed) {
      await _player.seek(Duration.zero);
      await _player.play();
      return;
    }

    await _load(url);
    await _player.play();
  }

  Future<void> _load(String url) async {
    _currentUrl = url;
    _loading = true;
    _emit();
    try {
      if (_player.processingState != ProcessingState.idle) {
        await _player.stop();
      }
      await _player
          .setAudioSource(
            AudioSource.uri(Uri.parse(url)),
            preload: true,
          )
          .timeout(const Duration(seconds: 10));
      _logger.info("Audio source loaded successfully", prefix: _prefix);
    } catch (e) {
      _logger.error("Error loading audio source: $e", prefix: _prefix);
    } finally {
      _loading = false;
      _emit();
    }
  }

  @override
  Future<void> dispose() async {
    await _playbackSubscription.cancel();
    await _playerStateSubscription.cancel();
    await _controller.close();
    await _player.dispose();
  }
}
