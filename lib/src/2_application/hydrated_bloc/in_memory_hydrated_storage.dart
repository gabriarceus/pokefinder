import 'package:hydrated_bloc/hydrated_bloc.dart';

/// In-memory implementation of [Storage] for testing and fallback environments.
class InMemoryHydratedStorage implements Storage {
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

/// Ensures [HydratedBloc.storage] is initialized, providing an [InMemoryHydratedStorage]
/// fallback if uninitialized.
void ensureHydratedStorage() {
  try {
    HydratedBloc.storage;
  } catch (_) {
    HydratedBloc.storage = InMemoryHydratedStorage();
  }
}
