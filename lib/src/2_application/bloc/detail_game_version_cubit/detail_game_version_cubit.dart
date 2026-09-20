import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon.dart';
import 'package:pokefinder/src/3_domain/helpers/game_version_mappings.dart';
import 'package:pokefinder/src/2_application/bloc/detail_game_version_cubit/detail_game_version_state.dart';

export 'detail_game_version_state.dart';

class DetailGameVersionCubit extends Cubit<DetailGameVersionState> {
  DetailGameVersionCubit() : super(const DetailGameVersionState());

  void initialize(Pokemon pokemon, {List<PokemonEncounter>? encounters}) {
    final versionsSet = <String>{};

    // 1. From moves
    for (final move in pokemon.moves) {
      final versions = GameVersionMappings.versionsForGroup(move.versionGroup);
      versionsSet.addAll(versions);
    }

    // 2. From encounters
    if (encounters != null) {
      for (final encounter in encounters) {
        versionsSet.addAll(encounter.versions);
      }
    }

    // 3. From held items
    for (final item in pokemon.heldItems) {
      if (item.version.isNotEmpty) {
        versionsSet.add(item.version);
      }
    }

    // 4. From game indices
    versionsSet.addAll(pokemon.gameIndices);

    final sortedVersions = versionsSet.toList();
    GameVersionMappings.sortVersions(sortedVersions);

    final sanitizedSelectedVersion = versionsSet.contains(state.selectedVersion)
        ? state.selectedVersion
        : DetailGameVersionState.allVersions;

    emit(
      state.copyWith(
        availableVersions: sortedVersions,
        selectedVersion: sanitizedSelectedVersion,
      ),
    );
  }

  void selectVersion(String version) {
    emit(state.copyWith(selectedVersion: version));
  }
}
