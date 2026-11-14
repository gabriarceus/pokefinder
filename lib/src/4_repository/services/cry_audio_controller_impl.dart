import 'dart:async';

import 'package:en_logger/en_logger.dart';
import 'package:injectable/injectable.dart';
import 'package:just_audio/just_audio.dart';
import 'package:meta/meta.dart';
import 'package:pokefinder/src/3_domain/services/cry_audio_controller.dart';

/// [CryAudioController] backed by a [just_audio] [AudioPlayer].
///
/// Each instance owns its own player and subscriptions; resolve a fresh
/// instance per screen and call [dispose] when done.
@Injectable(as: CryAudioController)
class JustAudioCryController implements CryAudioController {
  JustAudioCryController(this._logger) : _player = AudioPlayer() {
    _init();
  }

  @visibleForTesting
  JustAudioCryController.withPlayer(this._logger, this._player) {
    _init();
  }

  void _init() {
    _playbackSubscription = _player.playbackEventStream.listen(
      (event) {
        _logger.info(
          "Playback event: ${event.processingState}",
          prefix: _prefix,
        );
      },
      onError: (Object e, StackTrace stacktrace) {
        _logger.error("Playback error: $e", prefix: _prefix);
        _unavailable = true;
        _emit();
      },
    );
    _playerStateSubscription = _player.playerStateStream.listen((_) => _emit());
  }

  static const _prefix = 'CryAudioController';

  final EnLogger _logger;
  final AudioPlayer _player;
  final StreamController<CryPlaybackState> _controller =
      StreamController<CryPlaybackState>.broadcast();

  late final StreamSubscription<PlaybackEvent> _playbackSubscription;
  late final StreamSubscription<PlayerState> _playerStateSubscription;

  String? _currentUrl;
  bool _loading = false;
  bool _unavailable = false;
  int _generation = 0;
  CryPlaybackState _last = const CryPlaybackState();

  @override
  Stream<CryPlaybackState> get stateStream => _controller.stream;

  @override
  CryPlaybackState get state => _snapshot();

  CryPlaybackState _snapshot() {
    final playerState = _player.playerState;
    return CryPlaybackState(
      currentUrl: _currentUrl,
      playing: playerState.playing && !_unavailable,
      completed:
          playerState.processingState == ProcessingState.completed &&
          !_unavailable,
      loading: _loading,
      unavailable: _unavailable,
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
  Future<void> play(String url) async {
    final generation = ++_generation;
    final isCurrent = _currentUrl == url;
    if (isCurrent && !_unavailable) {
      await _player.seek(Duration.zero);
      if (generation != _generation) return;
      await _player.play();
      return;
    }
    final loaded = await _load(url, generation);
    if (loaded && generation == _generation) {
      await _player.play();
    }
  }

  @override
  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume.clamp(0.0, 1.0));
  }

  @override
  Future<void> toggle(String url) async {
    final generation = ++_generation;
    final playerState = _player.playerState;
    final isCurrent = _currentUrl == url;

    if (isCurrent &&
        !_unavailable &&
        playerState.playing &&
        playerState.processingState != ProcessingState.completed) {
      await _player.stop();
      return;
    }

    if (isCurrent &&
        !_unavailable &&
        playerState.processingState == ProcessingState.completed) {
      await _player.seek(Duration.zero);
      if (generation != _generation) return;
      await _player.play();
      return;
    }

    final loaded = await _load(url, generation);
    if (loaded && generation == _generation) {
      await _player.play();
    }
  }

  @override
  Future<void> stop() async {
    _generation++;
    _currentUrl = null;
    _loading = false;
    _unavailable = false;
    await _player.stop();
    _emit();
  }

  Future<bool> _load(String url, int generation) async {
    _currentUrl = url;
    _loading = true;
    _unavailable = false;
    _emit();
    try {
      if (_player.processingState != ProcessingState.idle) {
        await _player.stop();
      }
      if (generation != _generation) return false;
      await _player
          .setAudioSource(AudioSource.uri(Uri.parse(url)), preload: true)
          .timeout(const Duration(seconds: 10));
      _logger.info("Audio source loaded successfully", prefix: _prefix);
      return generation == _generation;
    } catch (e) {
      if (generation != _generation) return false;
      _logger.error("Error loading audio source: $e", prefix: _prefix);
      _unavailable = true;
      return false;
    } finally {
      if (generation == _generation) {
        _loading = false;
        _emit();
      }
    }
  }

  @override
  Future<void> dispose() async {
    _generation++;
    await _playbackSubscription.cancel();
    await _playerStateSubscription.cancel();
    await _controller.close();
    await _player.dispose();
  }
}
