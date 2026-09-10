import 'package:flutter/material.dart';
import 'package:pokefinder/src/1_presentation/extensions/language_ext.dart';
import 'package:pokefinder/src/1_presentation/widgets/detail/surface_card.dart';
import 'package:pokefinder/src/3_domain/services/cry_audio_controller.dart';

/// Visual mode of the cry play button, derived from playback state.
enum CryButtonMode { play, stop, replay, loading, unavailable }

/// Pure mapping from a playback [state] to the button mode for the cry at [url].
CryButtonMode cryButtonModeFor(CryPlaybackState state, String url) {
  if (url.isEmpty) return CryButtonMode.unavailable;
  final isCurrent = state.currentUrl == url;
  if (isCurrent && state.loading) return CryButtonMode.loading;
  if (isCurrent && state.unavailable) return CryButtonMode.unavailable;
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
    final t = context.t();

    return StreamBuilder<CryPlaybackState>(
      stream: controller.stateStream,
      initialData: controller.state,
      builder: (context, snapshot) {
        final mode = cryButtonModeFor(
          snapshot.data ?? const CryPlaybackState(),
          cryUrl,
        );

        final tooltipMessage = switch (mode) {
          CryButtonMode.loading => t.cryLoadingTooltip,
          CryButtonMode.stop => t.cryStopTooltip,
          CryButtonMode.replay => t.cryReplayTooltip,
          CryButtonMode.play => t.cryPlayTooltip,
          CryButtonMode.unavailable => t.cryUnavailableTooltip,
        };

        return Semantics(
          button: true,
          enabled: mode != CryButtonMode.loading,
          label: '$label: $tooltipMessage',
          child: Tooltip(
            message: tooltipMessage,
            child: SurfaceCard(
              borderRadius: 24,
              margin: EdgeInsets.zero,
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              child: InkWell(
                onTap: mode == CryButtonMode.loading
                    ? null
                    : () => controller.toggle(cryUrl),
                borderRadius: BorderRadius.circular(24),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _ModeIcon(mode: mode),
                      const SizedBox(width: 6),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: mode == CryButtonMode.unavailable
                              ? Theme.of(context).disabledColor
                              : Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ModeIcon extends StatelessWidget {
  const _ModeIcon({required this.mode});

  final CryButtonMode mode;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return switch (mode) {
      CryButtonMode.loading => SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2, color: primary),
      ),
      CryButtonMode.stop => Icon(Icons.stop_rounded, size: 18, color: primary),
      CryButtonMode.replay => Icon(
        Icons.replay_rounded,
        size: 18,
        color: primary,
      ),
      CryButtonMode.unavailable => Icon(
        Icons.volume_off_rounded,
        size: 18,
        color: Theme.of(context).disabledColor,
      ),
      CryButtonMode.play => Icon(
        Icons.volume_up_rounded,
        size: 18,
        color: primary,
      ),
    };
  }
}
