import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:pokefinder/src/3_domain/entities/language.dart';
import 'package:en_logger/en_logger.dart';

class LanguageState extends Equatable {
  const LanguageState({
    required this.languageId,
    required this.lastManualLanguageId,
  });

  final int languageId;
  final int lastManualLanguageId;

  @override
  List<Object?> get props => [languageId, lastManualLanguageId];
}

@injectable
class LanguageCubit extends HydratedCubit<LanguageState> {
  LanguageCubit(this._logger)
      : super(const LanguageState(
          languageId: -1, // Language.system.id
          lastManualLanguageId: 0, // Language.english.id
        ));

  final EnLogger _logger;
  static const _prefix = 'LanguageCubit';

  void setLanguage(int language) {
    _logger.info('Setting language to $language', prefix: _prefix);
    emit(LanguageState(
      languageId: language,
      lastManualLanguageId: state.lastManualLanguageId,
    ));
  }

  /// Switches to system language, remembering the current manual choice.
  void enableSystemLanguage() {
    _logger.info('Enabling system language', prefix: _prefix);
    final lastManual = state.languageId != -1 ? state.languageId : state.lastManualLanguageId;
    emit(LanguageState(
      languageId: -1,
      lastManualLanguageId: lastManual,
    ));
  }

  /// Restores the last manually chosen language.
  void disableSystemLanguage() {
    _logger.info(
      'Disabling system language, restoring last manual language: ${state.lastManualLanguageId}',
      prefix: _prefix,
    );
    emit(LanguageState(
      languageId: state.lastManualLanguageId,
      lastManualLanguageId: state.lastManualLanguageId,
    ));
  }

  // Method that returns the Locale based on the current value of the state
  Locale? getLanguageLocale() {
    switch (state.languageId) {
      case 1: // Language.italian.id
        return Language.italian.locale;
      case 0: // Language.english.id
        return Language.english.locale;
      default:
        return Language.system.locale;
    }
  }

  @override
  LanguageState fromJson(Map<String, dynamic> json) {
    final languageId = json['language'] as int? ?? -1;
    final lastManualLanguageId = json['lastManualLanguageId'] as int? ?? 0;
    return LanguageState(
      languageId: languageId,
      lastManualLanguageId: lastManualLanguageId,
    );
  }

  @override
  Map<String, dynamic> toJson(LanguageState state) => {
        'language': state.languageId,
        'lastManualLanguageId': state.lastManualLanguageId,
      };
}

