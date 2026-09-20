import 'package:en_logger/en_logger.dart';
import 'package:pokefinder/bootstrap.dart';
import 'package:pokefinder/src/2_application/application.dart';
import 'package:pokefinder/src/3_domain/domain.dart';

/// Single allowed construction point for blocs, cubits, and controllers used
/// below `lib/src/1_presentation/`.
///
/// Presentation widgets never call `getIt` directly; they obtain instances
/// through these functions instead. App-lifetime singletons provided at the
/// app root (`lib/main.dart`) are the only other sanctioned `getIt` call
/// sites. Cubits needing runtime data (e.g. [DetailMovesCubit]) stay
/// non-injectable and are created inline here with their static dependencies
/// resolved from the container.
HomeBloc createHomeBloc(String userInput) {
  final bloc = getIt<HomeBloc>()..add(FetchAllPokemonNamesEvent());
  if (userInput.isNotEmpty) {
    bloc.add(UserInputEvent(userInput));
  }
  return bloc;
}

/// Creates the detail [PokemonBloc] for [pokemonName] and starts its fetch.
PokemonBloc createPokemonBloc(String pokemonName) {
  return getIt<PokemonBloc>()..add(FetchPokemonEvent(pokemonName));
}

/// Creates the browsable Pokédex bloc and starts its index fetch.
PokedexBloc createPokedexBloc() {
  return getIt<PokedexBloc>()..add(const PokedexFetchIndexEvent());
}

/// Creates a [SpeciesCubit] and starts fetching [speciesUrl].
SpeciesCubit createSpeciesCubit(String speciesUrl) {
  return getIt<SpeciesCubit>()..fetchSpecies(speciesUrl);
}

/// Creates an [EvolutionCubit] and starts fetching [evolutionChainUrl].
EvolutionCubit createEvolutionCubit(String evolutionChainUrl) {
  return getIt<EvolutionCubit>()..fetchEvolutionChain(evolutionChainUrl);
}

/// Creates an [AbilityDetailCubit] and starts fetching [abilityName].
AbilityDetailCubit createAbilityDetailCubit(String abilityName) {
  return getIt<AbilityDetailCubit>()..fetchAbilityDetail(abilityName);
}

/// Creates a [MoveDetailCubit] and starts fetching [moveName].
MoveDetailCubit createMoveDetailCubit(String moveName) {
  return getIt<MoveDetailCubit>()..fetchMoveDetail(moveName);
}

/// Creates the runtime-data [DetailMovesCubit] for the given [moves].
DetailMovesCubit createDetailMovesCubit({required List<PokemonMove> moves}) {
  return DetailMovesCubit(moves: moves, logger: getIt<EnLogger>());
}

/// Resolves the shared cry-audio controller.
CryAudioController resolveCryAudioController() {
  return getIt<CryAudioController>();
}
