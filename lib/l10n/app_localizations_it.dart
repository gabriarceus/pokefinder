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

  @override
  String get about => 'Informazioni';

  @override
  String get weight => 'Peso';

  @override
  String get height => 'Altezza';

  @override
  String get pokemonCry => 'Verso del Pokemon';

  @override
  String get baseStats => 'Statistiche Base';

  @override
  String get statHp => 'PS';

  @override
  String get statAttack => 'Attacco';

  @override
  String get statDefense => 'Difesa';

  @override
  String get statSpAtk => 'Att. Sp.';

  @override
  String get statSpDef => 'Dif. Sp.';

  @override
  String get statSpeed => 'Velocità';

  @override
  String get statsNotAvailable => 'Statistiche non disponibili';

  @override
  String get clearCache => 'Svuota cache';

  @override
  String get cacheClearedSuccessfully => 'Cache svuotata con successo';
}
