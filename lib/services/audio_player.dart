import 'package:just_audio/just_audio.dart';

Future<void> setupAudioPlayer(player, String pokemon) async {

  player.playbackEventStream.listen((event) {},
      onError: (Object e, StackTrace stacktrace) {
  });

  try {
    await player.setAudioSource(AudioSource.uri(Uri.parse(pokemon)));
  } catch (e) {
    print("Error loading audio source: $e");
  }
}
