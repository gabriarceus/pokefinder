// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get searchTextField => 'Cerca Pokémon';

  @override
  String get searchButton => 'Cerca';

  @override
  String get loading => 'Caricamento...';

  @override
  String get details => 'Dettagli';

  @override
  String get backButton => 'Indietro';

  @override
  String get settings => 'Impostazioni';

  @override
  String get useDeviceLanguage => 'Usa la lingua del dispositivo';

  @override
  String get useDeviceLanguageInfo =>
      'Se attivato, l\'app userà la stessa lingua del tuo dispositivo.';
}
