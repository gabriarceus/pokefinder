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
}
