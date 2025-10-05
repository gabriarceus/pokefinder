import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:pokefinder/src/3_domain/models/language.dart';

class LanguageCubit extends HydratedCubit<int> {
  LanguageCubit() : super(Language.english.id);

  void setLanguage(int language) => emit(language);

  // Method that returns the Locale based on the current value of the state
  Locale getLanguageLocale() {
//FIXME: da migliorare
    if (state == Language.italian.id) {
      return Language.italian.locale;
    }
    return Language.english.locale;
  }

  @override
  int fromJson(Map<String, dynamic> json) => json['language'] as int;

  @override
  Map<String, int> toJson(int state) => {'language': state};
}
