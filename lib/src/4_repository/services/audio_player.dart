import 'dart:async';

import 'package:en_logger/en_logger.dart';
import 'package:just_audio/just_audio.dart';
import 'package:pokefinder/bootstrap.dart';

const _prefix = 'AudioPlayerSetup';

/// Active subscription to prevent duplicate listeners
StreamSubscription<PlaybackEvent>? _activeSubscription;

Future<void> setupAudioPlayer(AudioPlayer player, String cry) async {
  final logger = getIt<EnLogger>();

  // Cancel any previous listener to prevent duplicates
  await _activeSubscription?.cancel();

  _activeSubscription = player.playbackEventStream.listen((event) {
    logger.info("Playback event: ${event.processingState}", prefix: _prefix);
  }, onError: (Object e, StackTrace stacktrace) {
    logger.error("Playback error: $e", prefix: _prefix);
  });

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
