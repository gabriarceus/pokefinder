import 'package:en_logger/en_logger.dart';
import 'package:just_audio/just_audio.dart';
import 'package:pokefinder/bootstrap.dart';

const _prefix = 'AudioPlayerSetup';

Future<void> setupAudioPlayer(AudioPlayer player, String pokemon) async {
  final logger = getIt<EnLogger>();

  // Cancella eventuali listener precedenti
  player.playbackEventStream.listen((event) {
    logger.info("Playback event: ${event.processingState}", prefix: _prefix);
  }, onError: (Object e, StackTrace stacktrace) {
    logger.error("Playback error: $e", prefix: _prefix);
  });

  try {
    // Assicurati che il player sia in uno stato valido
    if (player.processingState != ProcessingState.idle) {
      await player.stop();
    }

    // Imposta l'audio source con timeout
    await player
        .setAudioSource(
          AudioSource.uri(Uri.parse(pokemon)),
          preload: true,
        )
        .timeout(const Duration(seconds: 10));

    logger.info("Audio source loaded successfully", prefix: _prefix);
  } catch (e) {
    logger.error("Error loading audio source: $e", prefix: _prefix);
    // Gestisci l'errore specifico -11849
    if (e.toString().contains('-11849')) {
      logger.error("Operation stopped - likely due to player lifecycle issues",
          prefix: _prefix);
    }
  }
}
