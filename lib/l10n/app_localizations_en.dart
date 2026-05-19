// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get searchTextField => 'Search Pokémon';

  @override
  String get searchButton => 'Search';

  @override
  String get loading => 'Loading...';

  @override
  String get details => 'Details';

  @override
  String get backButton => 'Back';

  @override
  String get settings => 'Settings';

  @override
  String get useDeviceLanguage => 'Use device language';

  @override
  String get useDeviceLanguageInfo =>
      'If enabled, the app will use your device\'s language.';

  @override
  String get about => 'About';

  @override
  String get weight => 'Weight';

  @override
  String get height => 'Height';

  @override
  String get pokemonCry => 'Pokemon Cry';

  @override
  String get baseStats => 'Base Stats';

  @override
  String get statHp => 'HP';

  @override
  String get statAttack => 'Attack';

  @override
  String get statDefense => 'Defense';

  @override
  String get statSpAtk => 'Sp. Atk';

  @override
  String get statSpDef => 'Sp. Def';

  @override
  String get statSpeed => 'Speed';

  @override
  String get statsNotAvailable => 'Stats not available';

  @override
  String get clearCache => 'Clear cache';

  @override
  String get cacheClearedSuccessfully => 'Cache cleared successfully';
}
