import 'package:flutter/widgets.dart';
import 'package:pokefinder/l10n/app_localizations.dart';
import 'package:pokefinder/src/3_domain/failures/pokemon_failure.dart';

/// Maps a [PokemonFailure] to its localized, user-facing message.
extension PokemonFailureLocalization on PokemonFailure {
  /// Returns the localized message for this failure, branching on the failure
  /// type rather than matching raw message strings.
  String localizedMessage(BuildContext context) {
    final t = AppLocalizations.of(context);
    return map(
      onFailure: (_) => t.errorUnauthorized,
      onBadRequest: (_) => t.errorBadRequest,
      onUnexpected: (_) => t.errorUnexpected,
    );
  }
}
