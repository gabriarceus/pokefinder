import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class PlaybackButton extends StatelessWidget {
  const PlaybackButton({
    super.key,
    required AudioPlayer player,
  }) : _player = player;

  final AudioPlayer _player;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayerState>(
      stream: _player.playerStateStream,
      builder: (context, snapshot) {
        final playerState = snapshot.data;
        final processingState = playerState?.processingState;
        final playing = playerState?.playing;
        if (playing != true) {
          return IconButton(
            icon: const Icon(Icons.play_arrow_rounded),
            onPressed: _player.play,
          );
        } else if (processingState != ProcessingState.completed) {
          return IconButton(
            icon: const Icon(Icons.stop_rounded),
            onPressed: () {
              _player.pause();
              _player.seek(Duration.zero);
            },
          );
        } else {
          return IconButton(
            icon: const Icon(Icons.replay_rounded),
            onPressed: () => _player.seek(Duration.zero),
          );
        }
      },
    );
  }
}
