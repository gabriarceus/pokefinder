import 'package:dartz/dartz.dart';
import 'package:en_logger/en_logger.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pokefinder/src/2_application/bloc/pokemon_form_details_cubit/pokemon_form_details_cubit.dart';
import 'package:pokefinder/src/3_domain/domain.dart';

class _MockEnLogger extends Mock implements EnLogger {}

class _MockPokemonRepository extends Mock implements IPokemonRepository {}

void main() {
  late _MockPokemonRepository repository;
  late PokemonFormDetailsCubit cubit;

  const megaX = PokemonFormDetails(
    id: 10034,
    name: 'charizard-mega-x',
    type1: PokemonType.fire,
    type2: PokemonType.dragon,
    spriteDefault: '',
    spriteShiny: '',
    artworkDefault: '',
    artworkShiny: '',
  );

  setUp(() {
    repository = _MockPokemonRepository();
    cubit = PokemonFormDetailsCubit(_MockEnLogger(), repository);
  });

  tearDown(() => cubit.close());

  test(
    'loads only the forms without types; a failed form has no entry',
    () async {
      when(
        () => repository.getFormDetails(
          PokeApiUrlHelper.pokemonUrl('charizard-mega-x'),
        ),
      ).thenAnswer((_) async => right(megaX));
      when(
        () => repository.getFormDetails(
          PokeApiUrlHelper.pokemonUrl('charizard-mega-y'),
        ),
      ).thenAnswer((_) async => left(const NetworkUnavailableFailure()));

      await cubit.load(const [
        PokemonForm(
          name: 'charizard',
          url: 'url/6/',
          type1: PokemonType.fire,
          type2: PokemonType.flying,
        ),
        PokemonForm(name: 'charizard-mega-x', url: 'url/10034/'),
        PokemonForm(name: 'charizard-mega-y', url: 'url/10035/'),
      ]);

      expect(cubit.state, {'charizard-mega-x': megaX});
      verifyNever(
        () =>
            repository.getFormDetails(PokeApiUrlHelper.pokemonUrl('charizard')),
      );
    },
  );
}
