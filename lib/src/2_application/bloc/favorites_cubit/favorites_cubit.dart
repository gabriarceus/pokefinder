import 'package:clock/clock.dart';
import 'package:en_logger/en_logger.dart';
import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:pokefinder/src/3_domain/domain.dart';

/// State of user-favorited Pokémon and sorting preferences.
class FavoritesState extends Equatable {
  const FavoritesState({
    this.favorites = const [],
    this.sortOrder = FavoriteSortOrder.idAscending,
  });

  /// All currently favorited Pokémon items.
  final List<FavoritePokemon> favorites;

  /// Current sorting strategy.
  final FavoriteSortOrder sortOrder;

  /// Returns [favorites] sorted according to [sortOrder].
  List<FavoritePokemon> get sortedFavorites {
    final list = List<FavoritePokemon>.from(favorites);
    switch (sortOrder) {
      case FavoriteSortOrder.idAscending:
        list.sort((a, b) => a.pokemon.id.compareTo(b.pokemon.id));
      case FavoriteSortOrder.idDescending:
        list.sort((a, b) => b.pokemon.id.compareTo(a.pokemon.id));
      case FavoriteSortOrder.nameAscending:
        list.sort(
          (a, b) => a.pokemon.name.toLowerCase().compareTo(
            b.pokemon.name.toLowerCase(),
          ),
        );
      case FavoriteSortOrder.nameDescending:
        list.sort(
          (a, b) => b.pokemon.name.toLowerCase().compareTo(
            a.pokemon.name.toLowerCase(),
          ),
        );
      case FavoriteSortOrder.recentlyAdded:
        list.sort((a, b) => b.addedAt.compareTo(a.addedAt));
    }
    return list;
  }

  /// Checks if [id] is present in [favorites].
  bool isFavorite(int id) => favorites.any((f) => f.pokemon.id == id);

  FavoritesState copyWith({
    List<FavoritePokemon>? favorites,
    FavoriteSortOrder? sortOrder,
  }) {
    return FavoritesState(
      favorites: favorites ?? this.favorites,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  List<Object?> get props => [favorites, sortOrder];
}

/// Manages persistent favorited Pokémon bookmarks.
@lazySingleton
class FavoritesCubit extends HydratedCubit<FavoritesState> {
  FavoritesCubit(this._logger, {Clock clock = const Clock()})
    : _clock = clock,
      super(const FavoritesState());

  static const _prefix = 'FavoritesCubit';
  final EnLogger _logger;
  final Clock _clock;

  /// Toggles favorite status for [pokemon].
  void toggleFavorite(PokemonSummary pokemon) {
    if (state.isFavorite(pokemon.id)) {
      removeFavorite(pokemon.id);
    } else {
      addFavorite(pokemon);
    }
  }

  /// Adds [pokemon] to favorites.
  void addFavorite(PokemonSummary pokemon) {
    _logger.info(
      'Adding favorite: ${pokemon.name} (#${pokemon.id})',
      prefix: _prefix,
    );
    final updated = List<FavoritePokemon>.from(state.favorites)
      ..removeWhere((f) => f.pokemon.id == pokemon.id)
      ..add(FavoritePokemon(pokemon: pokemon, addedAt: _clock.now()));
    emit(state.copyWith(favorites: updated));
  }

  /// Removes a Pokémon from favorites by its ID.
  void removeFavorite(int id) {
    _logger.info('Removing favorite ID: $id', prefix: _prefix);
    final updated = state.favorites
        .where((element) => element.pokemon.id != id)
        .toList();
    emit(state.copyWith(favorites: updated));
  }

  /// Updates the sorting order of the favorites list.
  void setSortOrder(FavoriteSortOrder order) {
    _logger.info('Updating favorites sort order to $order', prefix: _prefix);
    emit(state.copyWith(sortOrder: order));
  }

  /// Removes all favorited Pokémon entries.
  void clearFavorites() {
    _logger.info('Clearing all favorites', prefix: _prefix);
    emit(state.copyWith(favorites: const []));
  }

  /// Convenience check for whether [id] is favorited.
  bool isFavorite(int id) => state.isFavorite(id);

  @override
  FavoritesState fromJson(Map<String, dynamic> json) {
    final rawList = json['favorites'] as List<dynamic>? ?? const [];
    final favorites = <FavoritePokemon>[];
    for (final raw in rawList) {
      if (raw is! Map<String, dynamic>) continue;
      try {
        favorites.add(FavoritePokemon.fromJson(raw));
      } catch (_) {
        _logger.info('Evicting corrupt favorite record', prefix: _prefix);
      }
    }
    final sortIndex = json['sortOrder'] as int?;
    final sortOrder =
        (sortIndex != null &&
            sortIndex >= 0 &&
            sortIndex < FavoriteSortOrder.values.length)
        ? FavoriteSortOrder.values[sortIndex]
        : FavoriteSortOrder.idAscending;
    return FavoritesState(favorites: favorites, sortOrder: sortOrder);
  }

  @override
  Map<String, dynamic> toJson(FavoritesState state) => {
    'favorites': state.favorites.map((f) => f.toJson()).toList(),
    'sortOrder': state.sortOrder.index,
  };
}
