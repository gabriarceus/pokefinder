import 'package:material_ui/material_ui.dart';
import 'package:pokefinder/l10n/app_localizations.dart';

/// Combined [AppLocalizations] and Material, Cupertino, and Widgets delegates.
// gen-l10n references flutter_localizations' legacy Material delegate instead of material_ui.
const List<LocalizationsDelegate<dynamic>> appLocalizationsDelegates = [
  AppLocalizations.delegate,
  ...GlobalMaterialLocalizations.delegates,
];
