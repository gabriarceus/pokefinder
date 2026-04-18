import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:pokefinder/src/3_domain/entities/language.dart';

@injectable
class LanguageCubit extends HydratedCubit<int> {
  LanguageCubit() : super(Language.system.id);

  int _lastManualLanguageId = Language.english.id;

  void setLanguage(int language) => emit(language);

  /// Switches to system language, remembering the current manual choice.
  void enableSystemLanguage() {
    if (state != Language.system.id) {
      _lastManualLanguageId = state;
    }
    emit(Language.system.id);
  }

  /// Restores the last manually chosen language.
  void disableSystemLanguage() {
    emit(_lastManualLanguageId);
  }

  // Method that returns the Locale based on the current value of the state
  Locale? getLanguageLocale() {
    if (state == Language.italian.id) {
      return Language.italian.locale;
    } else if (state == Language.english.id) {
      return Language.english.locale;
    }
    return Language.system.locale;
  }

  @override
  int fromJson(Map<String, dynamic> json) {
    _lastManualLanguageId =
        json['lastManualLanguageId'] as int? ?? Language.english.id;
    return json['language'] as int? ?? Language.system.id;
  }

  @override
  Map<String, int> toJson(int state) => {
        'language': state,
        'lastManualLanguageId': _lastManualLanguageId,
      };
}
