import 'package:flutter_test/flutter_test.dart';
import 'package:pokefinder/src/1_presentation/widgets/detail/cry_play_button.dart';
import 'package:pokefinder/src/3_domain/services/cry_audio_controller.dart';

void main() {
  group('cryButtonModeFor', () {
    const url = 'cry-a';
    const otherUrl = 'cry-b';

    test('play when this url is not the current source', () {
      expect(
          cryButtonModeFor(const CryPlaybackState(), url), CryButtonMode.play);
      expect(
        cryButtonModeFor(
          const CryPlaybackState(currentUrl: otherUrl, playing: true),
          url,
        ),
        CryButtonMode.play,
      );
    });

    test('loading when this url is the current source and loading', () {
      expect(
        cryButtonModeFor(
          const CryPlaybackState(currentUrl: url, loading: true),
          url,
        ),
        CryButtonMode.loading,
      );
    });

    test('stop when this url is the current source and playing', () {
      expect(
        cryButtonModeFor(
          const CryPlaybackState(currentUrl: url, playing: true),
          url,
        ),
        CryButtonMode.stop,
      );
    });

    test('replay when this url is the current source and completed', () {
      expect(
        cryButtonModeFor(
          const CryPlaybackState(
            currentUrl: url,
            playing: true,
            completed: true,
          ),
          url,
        ),
        CryButtonMode.replay,
      );
    });
  });
}
