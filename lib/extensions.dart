import 'package:flutter/widgets.dart';
import 'package:pokefinder/l10n/app_localizations.dart';

/// Extension on BuildContext to provide easy access to localization methods
extension LocalizationExtension on BuildContext {
  AppLocalizations t() => AppLocalizations.of(this);
}
