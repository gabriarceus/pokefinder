import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:pokefinder/src/3_domain/entities/language.dart';
import 'package:en_logger/en_logger.dart';

const _languageKey = 'language';

class LanguageState extends Equatable {
  const LanguageState({required this.languageId});

  /// Id of the selected [Language]; [Language.system] follows the device.
  final int languageId;

  /// Locale for the currently selected language, or `null` to follow the
  /// system language. Driven by the [Language] entity so a newly added
  /// selectable language is handled automatically.
  Locale? get locale {
    final language = languageId == Language.system.id
        ? Language.system
        : Language.selectable.firstWhere(
            (language) => language.id == languageId,
            orElse: () => Language.system,
          );
    final languageCode = language.languageCode;
    if (languageCode == null) return null;
    return Locale(languageCode, language.countryCode);
  }

  @override
  List<Object?> get props => [languageId];
}

@lazySingleton
class LanguageCubit extends HydratedCubit<LanguageState> {
  LanguageCubit(this._logger)
    : super(LanguageState(languageId: Language.system.id));

  final EnLogger _logger;
  static const _prefix = 'LanguageCubit';

  /// Selects the language with id [language]; [Language.system] follows the
  /// device language.
  void setLanguage(int language) {
    _logger.info('Setting language to $language', prefix: _prefix);
    emit(LanguageState(languageId: language));
  }

  @override
  LanguageState fromJson(Map<String, dynamic> json) {
    return LanguageState(
      languageId: json[_languageKey] as int? ?? Language.system.id,
    );
  }

  @override
  Map<String, dynamic> toJson(LanguageState state) => {
    _languageKey: state.languageId,
  };
}
