import 'package:flutter/material.dart';
import 'package:pokefinder/l10n/app_localizations.dart';
import 'package:pokefinder/src/3_domain/failures/pokemon_failure.dart';

extension PokemonFailureLocalization on PokemonFailure {
  String localizedMessage(BuildContext context) {
    final t = AppLocalizations.of(context);
    return switch (this) {
      PokemonNotFoundFailure() => t.errorPokemonNotFound,
      NetworkUnavailableFailure() => t.errorNetworkUnavailable,
      RequestTimeoutFailure() => t.errorRequestTimeout,
      RateLimitedFailure() => t.errorRateLimited,
      ServerFailure() => t.errorServer,
      InvalidResponseFailure() => t.errorInvalidResponse,
      StorageFailure() => t.errorStorage,
      UnauthorizedFailure() => t.errorUnauthorized,
      BadRequestFailure() => t.errorBadRequest,
      UnexpectedFailure() => t.errorUnexpected,
    };
  }
}
