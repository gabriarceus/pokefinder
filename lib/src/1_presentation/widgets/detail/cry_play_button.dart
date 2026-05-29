import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:pokefinder/src/4_repository/services/audio_player.dart';

class CryPlayButton extends StatefulWidget {
  const CryPlayButton({
    super.key,
    required this.player,
    required this.cryUrl,
    required this.label,
  });

  final AudioPlayer player;
  final String cryUrl;
  final String label;

  @override
  State<CryPlayButton> createState() => _CryPlayButtonState();
}

class _CryPlayButtonState extends State<CryPlayButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayerState>(
      stream: widget.player.playerStateStream,
      builder: (context, snapshot) {
        final playerState = snapshot.data;
        final playing = playerState?.playing ?? false;
        final processingState = playerState?.processingState ?? ProcessingState.idle;
        final sequence = widget.player.audioSource?.sequence;
        final isThisSource = sequence != null &&
            sequence.isNotEmpty &&
            sequence.first is UriAudioSource &&
            (sequence.first as UriAudioSource).uri.toString() == widget.cryUrl;

        final isCompleted = isThisSource && processingState == ProcessingState.completed;
        final isCurrentlyPlaying = playing && isThisSource && processingState != ProcessingState.completed;

        return Card(
          elevation: 0,
          color: Theme.of(context)
              .colorScheme
              .surfaceContainerHighest
              .withValues(alpha: 0.3),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.label,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13),
                ),
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                else
                  IconButton(
                    icon: Icon(
                      isCurrentlyPlaying
                          ? Icons.stop_rounded
                          : isCompleted
                              ? Icons.replay_rounded
                              : Icons.play_arrow_rounded,
                      color: Theme.of(context).primaryColor,
                    ),
                    onPressed: () async {
                      if (isCurrentlyPlaying) {
                        await widget.player.stop();
                      } else if (isCompleted) {
                        await widget.player.seek(Duration.zero);
                        await widget.player.play();
                      } else {
                        setState(() {
                          _isLoading = true;
                        });
                        await setupAudioPlayer(widget.player, widget.cryUrl);
                        if (mounted) {
                          setState(() {
                            _isLoading = false;
                          });
                        }
                        await widget.player.play();
                      }
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
