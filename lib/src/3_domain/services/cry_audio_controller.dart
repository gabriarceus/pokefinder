import 'package:equatable/equatable.dart';

/// Plays Pokémon cries and exposes their playback state to the UI.
///
/// A single controller drives one shared player; callers identify a cry by its
/// URL. The owner must call [dispose] to release the underlying resources.
abstract class CryAudioController {
  /// Emits a snapshot whenever playback state changes.
  Stream<CryPlaybackState> get stateStream;

  /// The current playback snapshot (useful as a stream's initial value).
  CryPlaybackState get state;

  /// Toggles playback for [url]: loads and plays it when it is not the current
  /// source, restarts it when completed, and stops it when it is playing.
  Future<void> toggle(String url);

  /// Releases the player and any subscriptions. Must be called by the owner.
  Future<void> dispose();
}

/// Immutable playback snapshot for the shared cry player.
class CryPlaybackState extends Equatable {
  const CryPlaybackState({
    this.currentUrl,
    this.playing = false,
    this.completed = false,
    this.loading = false,
  });

  /// URL of the currently loaded cry, or `null` when nothing is loaded.
  final String? currentUrl;

  /// Whether the current cry is playing.
  final bool playing;

  /// Whether the current cry has finished playing.
  final bool completed;

  /// Whether the current cry is being loaded.
  final bool loading;

  @override
  List<Object?> get props => [currentUrl, playing, completed, loading];
}
