import 'package:flutter/material.dart';
import 'package:pokefinder/src/3_domain/services/cry_audio_controller.dart';

/// Visual mode of the cry play button, derived from playback state.
enum CryButtonMode { play, stop, replay, loading }

/// Pure mapping from a playback [state] to the button mode for the cry at [url].
CryButtonMode cryButtonModeFor(CryPlaybackState state, String url) {
  final isCurrent = state.currentUrl == url;
  if (isCurrent && state.loading) return CryButtonMode.loading;
  if (isCurrent && state.completed) return CryButtonMode.replay;
  if (isCurrent && state.playing) return CryButtonMode.stop;
  return CryButtonMode.play;
}

class CryPlayButton extends StatelessWidget {
  const CryPlayButton({
    super.key,
    required this.controller,
    required this.cryUrl,
    required this.label,
  });

  final CryAudioController controller;
  final String cryUrl;
  final String label;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<CryPlaybackState>(
      stream: controller.stateStream,
      initialData: controller.state,
      builder: (context, snapshot) {
        final mode = cryButtonModeFor(
          snapshot.data ?? const CryPlaybackState(),
          cryUrl,
        );

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
                  label,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13),
                ),
                if (mode == CryButtonMode.loading)
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
                      switch (mode) {
                        CryButtonMode.stop => Icons.stop_rounded,
                        CryButtonMode.replay => Icons.replay_rounded,
                        CryButtonMode.play => Icons.play_arrow_rounded,
                        CryButtonMode.loading => Icons.play_arrow_rounded,
                      },
                      color: Theme.of(context).primaryColor,
                    ),
                    onPressed: () => controller.toggle(cryUrl),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
