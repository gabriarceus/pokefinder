import 'package:en_logger/en_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pokefinder/src/2_application/hydrated_bloc/language_storage.dart';
import 'package:pokefinder/src/3_domain/entities/language.dart';

class _MockEnLogger extends Mock implements EnLogger {}

/// In-memory [Storage] backing hydrated cubits under test.
class _InMemoryStorage implements Storage {
  final Map<String, dynamic> _entries = {};

  @override
  dynamic read(String key) => _entries[key];

  @override
  Future<void> write(String key, dynamic value) async => _entries[key] = value;

  @override
  Future<void> delete(String key) async => _entries.remove(key);

  @override
  Future<void> clear() async => _entries.clear();

  @override
  Future<void> close() async {}
}

void main() {
  late _InMemoryStorage storage;

  setUp(() {
    storage = _InMemoryStorage();
    HydratedBloc.storage = storage;
  });

  LanguageCubit buildCubit() => LanguageCubit(_MockEnLogger());

  group('locale resolution', () {
    test('follows the system language by default', () {
      expect(buildCubit().state.locale, isNull);
    });

    test('resolves a manually selected language to its locale', () {
      final cubit = buildCubit()..setLanguage(Language.italian.id);

      expect(cubit.state.locale, const Locale('it', 'IT'));
    });

    test('falls back to the system language for an unknown id', () {
      final cubit = buildCubit()..setLanguage(9999);

      expect(cubit.state.locale, isNull);
    });
  });

  group('system language toggle', () {
    test('enabling it remembers the current manual choice', () {
      final cubit = buildCubit()
        ..setLanguage(Language.italian.id)
        ..enableSystemLanguage();

      expect(cubit.state.languageId, Language.system.id);
      expect(cubit.state.lastManualLanguageId, Language.italian.id);
    });

    test('enabling it twice keeps the original manual choice', () {
      final cubit = buildCubit()
        ..setLanguage(Language.italian.id)
        ..enableSystemLanguage()
        ..enableSystemLanguage();

      expect(cubit.state.lastManualLanguageId, Language.italian.id);
    });

    test('disabling it restores the remembered manual choice', () {
      final cubit = buildCubit()
        ..setLanguage(Language.italian.id)
        ..enableSystemLanguage()
        ..disableSystemLanguage();

      expect(cubit.state.languageId, Language.italian.id);
      expect(cubit.state.locale, const Locale('it', 'IT'));
    });
  });

  group('persistence', () {
    test('a selected language survives a cubit restart', () async {
      final cubit = buildCubit()..setLanguage(Language.italian.id);
      await cubit.close();

      expect(buildCubit().state.languageId, Language.italian.id);
    });

    test('the system-language choice survives a cubit restart', () async {
      final cubit = buildCubit()
        ..setLanguage(Language.italian.id)
        ..enableSystemLanguage();
      await cubit.close();

      final restored = buildCubit();
      expect(restored.state.languageId, Language.system.id);
      expect(restored.state.lastManualLanguageId, Language.italian.id);
    });

    test('a stored payload missing both keys falls back to the defaults', () {
      final restored = buildCubit().fromJson(const {});

      expect(restored.languageId, Language.system.id);
      expect(restored.lastManualLanguageId, Language.english.id);
    });
  });
}
