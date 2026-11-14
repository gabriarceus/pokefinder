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
  final bloc = getIt<HomeBloc>()..add(LoadIndex());
  if (userInput.isNotEmpty) {
    bloc.add(SearchInputChanged(userInput));
  }
  return bloc;
}

/// Creates the detail [PokemonDetailBloc] for [pokemonName] and starts its fetch.
PokemonDetailBloc createPokemonDetailBloc(String pokemonName) {
  return getIt<PokemonDetailBloc>()..add(FetchPokemonEvent(pokemonName));
}

/// Creates a [PokemonListCubit] and starts loading [pokemonNames].
PokemonListCubit createPokemonListCubit(List<String> pokemonNames) {
  return getIt<PokemonListCubit>()..load(pokemonNames);
}

/// Creates a [PokemonFormDetailsCubit] and starts loading the forms of
/// [forms] that have no types.
PokemonFormDetailsCubit createPokemonFormDetailsCubit(List<PokemonForm> forms) {
  return getIt<PokemonFormDetailsCubit>()..load(forms);
}

/// Creates the browsable Pokédex bloc and starts its index fetch.
PokedexBloc createPokedexBloc() {
  return getIt<PokedexBloc>()..add(const PokedexFetchIndexEvent());
}

/// Creates a [LoadCubit] for the species at [speciesUrl] and starts loading.
LoadCubit<PokemonSpecies> createSpeciesCubit(String speciesUrl) {
  return LoadCubit(
    () => getIt<IPokemonRepository>().getPokemonSpecies(speciesUrl),
    getIt<EnLogger>(),
  )..load();
}

/// Creates a [LoadCubit] for the evolution chain at [evolutionChainUrl] and
/// starts loading.
LoadCubit<EvolutionChain> createEvolutionCubit(String evolutionChainUrl) {
  return LoadCubit(
    () => getIt<IPokemonRepository>().getEvolutionChain(evolutionChainUrl),
    getIt<EnLogger>(),
  )..load();
}

/// Creates a [LoadCubit] for the ability [abilityName] and starts loading.
LoadCubit<AbilityDetail> createAbilityDetailCubit(String abilityName) {
  return LoadCubit(
    () => getIt<IPokemonRepository>().getAbilityDetail(abilityName),
    getIt<EnLogger>(),
  )..load();
}

/// Creates a [LoadCubit] for the move [moveName] and starts loading.
LoadCubit<MoveDetail> createMoveDetailCubit(String moveName) {
  return LoadCubit(
    () => getIt<IPokemonRepository>().getMoveDetail(moveName),
    getIt<EnLogger>(),
  )..load();
}

/// Creates the runtime-data [DetailMovesCubit] for the given [moves],
/// starting on [gameVersion].
DetailMovesCubit createDetailMovesCubit({
  required List<PokemonMove> moves,
  required MoveNameResolver moveName,
  required String gameVersion,
}) {
  return DetailMovesCubit(
    moves: moves,
    moveName: moveName,
    logger: getIt<EnLogger>(),
    gameVersion: gameVersion,
  );
}

/// Creates a new cry-audio controller.
CryAudioController resolveCryAudioController() {
  return getIt<CryAudioController>();
}
