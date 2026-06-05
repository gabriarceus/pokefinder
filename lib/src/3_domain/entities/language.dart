class Language {
  const Language({
    required this.id,
    required this.description,
    required this.nativeName,
    this.languageCode,
    this.countryCode,
  });

  final int id;
  final String description;
  final String nativeName;

  /// IETF language subtag (e.g. `en`), or `null` to follow the system language.
  final String? languageCode;

  /// IETF region subtag (e.g. `US`), or `null` when unspecified.
  final String? countryCode;

  static const Language system =
      Language(id: -1, description: 'System', nativeName: '');
  static const Language english = Language(
      id: 0,
      description: 'ENG',
      nativeName: 'English',
      languageCode: 'en',
      countryCode: 'US');
  static const Language italian = Language(
      id: 1,
      description: 'ITA',
      nativeName: 'Italiano',
      languageCode: 'it',
      countryCode: 'IT');

  /// All languages the user can manually select.
  static const List<Language> selectable = [english, italian];
}
