import 'package:flutter/material.dart';

class Language {
  final int id;
  final String description;
  final Locale locale;

  const Language({
    required this.id,
    required this.description,
    required this.locale,
  });
//FIXME: da migliorare
  static const Language english =
      Language(id: 0, description: 'ENG', locale: Locale('en', 'US'));
  static const Language italian =
      Language(id: 1, description: 'ITA', locale: Locale('it', 'IT'));
}
