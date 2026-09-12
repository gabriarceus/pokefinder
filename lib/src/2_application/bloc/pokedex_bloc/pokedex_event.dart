part of 'pokedex_bloc.dart';

@immutable
sealed class PokedexEvent extends Equatable {
  const PokedexEvent();

  @override
  List<Object?> get props => [];
}

/// Requests fetching the Pokémon catalog index.
final class PokedexFetchIndexEvent extends PokedexEvent {
  const PokedexFetchIndexEvent({this.forceRefresh = false});

  final bool forceRefresh;

  @override
  List<Object?> get props => [forceRefresh];
}

/// Updates the active search query for the Pokédex index.
final class PokedexSearchQueryChangedEvent extends PokedexEvent {
  const PokedexSearchQueryChangedEvent(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

/// Toggles inclusion of a [PokemonType] in the active type filters.
final class PokedexTypeFilterToggledEvent extends PokedexEvent {
  const PokedexTypeFilterToggledEvent(this.type);

  final PokemonType type;

  @override
  List<Object?> get props => [type];
}

/// Updates the selected generation filter (1-9, or null for all).
final class PokedexGenerationFilterChangedEvent extends PokedexEvent {
  const PokedexGenerationFilterChangedEvent(this.generation);

  final int? generation;

  @override
  List<Object?> get props => [generation];
}

/// Updates the Pokédex sort order strategy.
final class PokedexSortOrderChangedEvent extends PokedexEvent {
  const PokedexSortOrderChangedEvent(this.sortOrder);

  final PokedexSortOrder sortOrder;

  @override
  List<Object?> get props => [sortOrder];
}

/// Clears all active filters and resets sort to default.
final class PokedexClearFiltersEvent extends PokedexEvent {
  const PokedexClearFiltersEvent();
}

/// Loads the next page of filtered Pokémon entries.
final class PokedexLoadMoreEvent extends PokedexEvent {
  const PokedexLoadMoreEvent();
}

/// Selects a random Pokémon from the current catalog for navigation.
final class PokedexSelectRandomPokemonEvent extends PokedexEvent {
  const PokedexSelectRandomPokemonEvent();
}

/// Resets the one-time random navigation target after navigation completes.
final class PokedexRandomNavigationDoneEvent extends PokedexEvent {
  const PokedexRandomNavigationDoneEvent();
}
