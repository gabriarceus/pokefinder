import 'dart:async';

import 'package:en_logger/en_logger.dart';
import 'package:just_audio/just_audio.dart';
import 'package:pokefinder/bootstrap.dart';

const _prefix = 'AudioPlayerSetup';

/// Subscribes a diagnostic listener to [player]'s playback events.
///
/// The returned subscription is owned by the caller and must be cancelled
/// (e.g. in the owning State's `dispose`) before the player itself is
/// disposed. Bind one listener per player for its whole lifetime instead of
/// recreating it on every source change.
StreamSubscription<PlaybackEvent> listenPlaybackEvents(AudioPlayer player) {
  final logger = getIt<EnLogger>();

  return player.playbackEventStream.listen(
    (event) {
      logger.info("Playback event: ${event.processingState}", prefix: _prefix);
    },
    onError: (Object e, StackTrace stacktrace) {
      logger.error("Playback error: $e", prefix: _prefix);
    },
  );
}

/// Loads [cry] as the audio source of [player].
///
/// Stops the player when it is not idle, then sets the source with preload and
/// a bounded timeout. Loading failures are logged and swallowed so a broken
/// audio URL never crashes the caller.
Future<void> setupAudioPlayer(AudioPlayer player, String cry) async {
  final logger = getIt<EnLogger>();

  try {
    // Ensure the player is in a valid state
    if (player.processingState != ProcessingState.idle) {
      await player.stop();
    }

    // Set the audio source with timeout
    await player
        .setAudioSource(
          AudioSource.uri(Uri.parse(cry)),
          preload: true,
        )
        .timeout(const Duration(seconds: 10));

    logger.info("Audio source loaded successfully", prefix: _prefix);
  } catch (e) {
    logger.error("Error loading audio source: $e", prefix: _prefix);
    if (e.toString().contains('-11849')) {
      logger.error("Operation stopped - likely due to player lifecycle issues",
          prefix: _prefix);
    }
  }
}
