import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:pokefinder/language.dart';

class LanguageCubit extends HydratedCubit<int> {
  LanguageCubit() : super(Language.english.id);

  void setLanguage(int language) => emit(language);
  // Metodo che restituisce il Locale in base al valore corrente dello state
  Locale getLanguageLocale() {
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
