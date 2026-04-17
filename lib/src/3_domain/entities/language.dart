import 'package:flutter/material.dart';

class Language {
  final int id;
  final String description;
  final String nativeName;
  final Locale? locale;

  const Language({
    required this.id,
    required this.description,
    required this.nativeName,
    required this.locale,
  });

  static const Language system =
      Language(id: -1, description: 'System', nativeName: '', locale: null);
  static const Language english =
      Language(id: 0, description: 'ENG', nativeName: 'English', locale: Locale('en', 'US'));
  static const Language italian =
      Language(id: 1, description: 'ITA', nativeName: 'Italiano', locale: Locale('it', 'IT'));

  /// All languages the user can manually select.
  static const List<Language> selectable = [english, italian];
}
