import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:en_logger/en_logger.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pokefinder/src/2_application/bloc/detail_bloc/detail_bloc.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon_sprites.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon_type.dart';
import 'package:pokefinder/src/3_domain/failures/pokemon_failure.dart';
import 'package:pokefinder/src/3_domain/repositories/i_pokemon_repository.dart';
import 'package:pokefinder/src/3_domain/value_objects/pokemon_name.dart';

import '../fixtures/pokemon_fixture.dart';

class _MockPokemonRepository extends Mock implements IPokemonRepository {}

class _MockEnLogger extends Mock implements EnLogger {}

const _megaForm = PokemonForm(
  name: 'venusaur-mega',
  url: 'https://pokeapi.co/api/v2/pokemon-form/10033/',
);

const _megaDetails = PokemonFormDetails(
  name: 'venusaur-mega',
  type1: PokemonType.grass,
  type2: PokemonType.poison,
  spriteDefault: 'mega.png',
  spriteShiny: 'mega-shiny.png',
  artworkDefault: 'mega-art.png',
  artworkShiny: 'mega-art-shiny.png',
);

const _encounters = [
  PokemonEncounter(rawLocationAreaName: 'Viridian Forest', versions: ['red']),
];

void main() {
  setUpAll(() {
    registerFallbackValue(PokemonName('placeholder'));
  });

  late _MockPokemonRepository repository;
  late _MockEnLogger logger;
  late PokemonDetailBloc bloc;

  setUp(() {
    repository = _MockPokemonRepository();
    logger = _MockEnLogger();
    bloc = PokemonDetailBloc(repository, logger);

    when(
      () => repository.getEncounters(any()),
    ).thenAnswer((_) async => right(const []));
  });

  tearDown(() => bloc.close());

  /// Drives a successful fetch to completion and returns the resulting state.
  Future<PokemonBlocSuccess> fetchSuccessfully(Pokemon pokemon) async {
    when(
      () => repository.getPokemon(any()),
    ).thenAnswer((_) async => right(pokemon));
    bloc.add(FetchPokemonEvent(pokemon.name));
    await pumpEventQueue();
    return bloc.state as PokemonBlocSuccess;
  }

  group('fetching a Pokémon', () {
    test('a blank name is rejected without hitting the repository', () async {
      bloc.add(FetchPokemonEvent('   '));
      await pumpEventQueue();

      expect(bloc.state, isA<PokemonBlocInitial>());
      verifyNever(() => repository.getPokemon(any()));
    });

    test('emits loading then failure when the fetch fails', () async {
      when(
        () => repository.getPokemon(any()),
      ).thenAnswer((_) async => left(const BadRequestFailure()));

      final emitted = <PokemonBlocState>[];
      final subscription = bloc.stream.listen(emitted.add);

      bloc.add(FetchPokemonEvent('missingno'));
      await pumpEventQueue();
      await subscription.cancel();

      expect(emitted, [
        PokemonBlocLoading(),
        PokemonBlocFailure(const BadRequestFailure()),
      ]);
    });

    test(
      'emits loading, then success with the default form selected',
      () async {
        final pokemon = buildPokemon(
          name: 'venusaur',
          sprites: const PokemonSprites(
            frontShiny: 'shiny.png',
            artworkDefault: 'art.png',
          ),
        );
        when(
          () => repository.getPokemon(any()),
        ).thenAnswer((_) async => right(pokemon));

        final emitted = <PokemonBlocState>[];
        final subscription = bloc.stream.listen(emitted.add);

        bloc.add(FetchPokemonEvent('venusaur'));
        await pumpEventQueue();
        await subscription.cancel();

        expect(emitted.first, PokemonBlocLoading());
        final firstSuccess = emitted[1] as PokemonBlocSuccess;
        expect(firstSuccess.pokemon, pokemon);
        expect(firstSuccess.isLoadingEncounters, isTrue);
        expect(
          firstSuccess.selectedFormDetails,
          PokemonFormDetails.fromPokemon(pokemon),
        );
        // B2: the form getters expose the active form without the caller
        // having to know whether a form has been selected yet.
        expect(
          firstSuccess.formDetails,
          PokemonFormDetails.fromPokemon(pokemon),
        );
        expect(firstSuccess.summary.id, pokemon.id);
        expect(firstSuccess.summary.name, 'venusaur');
        expect(firstSuccess.summary.spriteUrl, pokemon.sprite);
        expect(firstSuccess.summary.types, [PokemonType.grass]);
      },
    );

    test('loads encounters in the background after the Pokémon', () async {
      when(
        () => repository.getEncounters(any()),
      ).thenAnswer((_) async => right(_encounters));

      final state = await fetchSuccessfully(buildPokemon());

      expect(state.isLoadingEncounters, isFalse);
      expect(state.encounters, _encounters);
      expect(state.encountersFailure, isNull);
      verify(
        () => repository.getEncounters(
          'https://pokeapi.co/api/v2/pokemon/1/encounters',
        ),
      ).called(1);
    });

    test(
      'an encounters failure is surfaced without losing the Pokémon',
      () async {
        when(
          () => repository.getEncounters(any()),
        ).thenAnswer((_) async => left(const UnexpectedFailure('boom')));

        final state = await fetchSuccessfully(buildPokemon(name: 'venusaur'));

        expect(state.pokemon.name, 'venusaur');
        expect(state.isLoadingEncounters, isFalse);
        expect(state.encountersFailure, const UnexpectedFailure('boom'));
      },
    );

    test(
      'a stale encounters response does not overwrite a newer Pokémon',
      () async {
        final first = buildPokemon(id: 1, name: 'bulbasaur');
        final second = buildPokemon(id: 2, name: 'ivysaur');

        final staleEncounters =
            Completer<Either<PokemonFailure, List<PokemonEncounter>>>();
        var encountersCall = 0;
        when(() => repository.getEncounters(any())).thenAnswer((_) {
          encountersCall++;
          return encountersCall == 1
              ? staleEncounters.future
              : Future.value(right(const []));
        });

        when(
          () => repository.getPokemon(any()),
        ).thenAnswer((_) async => right(first));
        bloc.add(FetchPokemonEvent('bulbasaur'));
        await pumpEventQueue();

        when(
          () => repository.getPokemon(any()),
        ).thenAnswer((_) async => right(second));
        bloc.add(FetchPokemonEvent('ivysaur'));
        await pumpEventQueue();

        staleEncounters.complete(right(_encounters));
        await pumpEventQueue();

        final state = bloc.state as PokemonBlocSuccess;
        expect(state.pokemon.id, 2);
        expect(state.encounters, isEmpty);
      },
    );

    test(
      'a superseded fetch emits nothing after its request resolves late',
      () async {
        final first = buildPokemon(id: 1, name: 'bulbasaur');
        final second = buildPokemon(id: 2, name: 'ivysaur');

        final staleFetch = Completer<Either<PokemonFailure, Pokemon>>();
        var fetchCall = 0;
        when(() => repository.getPokemon(any())).thenAnswer((_) {
          fetchCall++;
          return fetchCall == 1
              ? staleFetch.future
              : Future.value(right(second));
        });

        bloc.add(FetchPokemonEvent('bulbasaur'));
        await pumpEventQueue();

        bloc.add(FetchPokemonEvent('ivysaur'));
        await pumpEventQueue();

        // The superseded request resolving must not surface a failure, nor
        // revert the state away from the newer, already loaded Pokémon.
        final emittedAfterIvysaur = <PokemonBlocState>[];
        final subscription = bloc.stream.listen(emittedAfterIvysaur.add);

        staleFetch.complete(left(const NetworkUnavailableFailure()));
        await pumpEventQueue();
        await subscription.cancel();

        expect(emittedAfterIvysaur, isEmpty);
        final state = bloc.state as PokemonBlocSuccess;
        expect(state.pokemon.id, 2);
        expect(state.pokemon.name, 'ivysaur');
        // Sanity check on the fixture that the first request would have
        // returned a different Pokémon.
        expect(first.id, isNot(2));
      },
    );
  });

  group('retrying encounters', () {
    test('retries encounters loading after a failure', () async {
      when(
        () => repository.getEncounters(any()),
      ).thenAnswer((_) async => left(const NetworkUnavailableFailure()));

      final state = await fetchSuccessfully(buildPokemon(name: 'venusaur'));
      expect(state.encountersFailure, const NetworkUnavailableFailure());

      when(
        () => repository.getEncounters(any()),
      ).thenAnswer((_) async => right(_encounters));

      bloc.add(RetryPokemonEncountersEvent());
      await pumpEventQueue();

      final updatedState = bloc.state as PokemonBlocSuccess;
      expect(updatedState.isLoadingEncounters, isFalse);
      expect(updatedState.encounters, _encounters);
      expect(updatedState.encountersFailure, isNull);
    });
  });

  group('switching form', () {
    test('is ignored before a Pokémon has been loaded', () async {
      bloc.add(SelectPokemonFormEvent(_megaForm));
      await pumpEventQueue();

      expect(bloc.state, isA<PokemonBlocInitial>());
      verifyNever(() => repository.getFormDetails(any()));
    });

    test('loads the details of a non-default form', () async {
      await fetchSuccessfully(
        buildPokemon(name: 'venusaur', forms: [_megaForm]),
      );
      when(
        () => repository.getFormDetails(_megaForm.url),
      ).thenAnswer((_) async => right(_megaDetails));

      final emitted = <PokemonBlocSuccess>[];
      final subscription = bloc.stream.cast<PokemonBlocSuccess>().listen(
        emitted.add,
      );

      bloc.add(SelectPokemonFormEvent(_megaForm));
      await pumpEventQueue();
      await subscription.cancel();

      expect(emitted.first.isLoadingForm, isTrue);
      expect(emitted.last.isLoadingForm, isFalse);
      expect(emitted.last.selectedFormDetails, _megaDetails);
      expect(emitted.last.formFailure, isNull);
      // B2: formDetails/summary follow the selected form.
      expect(emitted.last.formDetails, _megaDetails);
      expect(emitted.last.summary.name, 'venusaur-mega');
      expect(emitted.last.summary.spriteUrl, 'mega.png');
      expect(emitted.last.summary.types, [
        PokemonType.grass,
        PokemonType.poison,
      ]);
    });

    test(
      'a form failure is surfaced and the previous selection is kept, recording failedForm',
      () async {
        final pokemon = buildPokemon(name: 'venusaur', forms: [_megaForm]);
        await fetchSuccessfully(pokemon);
        when(
          () => repository.getFormDetails(any()),
        ).thenAnswer((_) async => left(const UnexpectedFailure('nope')));

        bloc.add(SelectPokemonFormEvent(_megaForm));
        await pumpEventQueue();

        final state = bloc.state as PokemonBlocSuccess;
        expect(state.isLoadingForm, isFalse);
        expect(state.formFailure, const UnexpectedFailure('nope'));
        expect(state.failedForm, _megaForm);
        expect(
          state.selectedFormDetails,
          PokemonFormDetails.fromPokemon(pokemon),
        );
      },
    );

    test('clearing form failure resets formFailure and failedForm', () async {
      final pokemon = buildPokemon(name: 'venusaur', forms: [_megaForm]);
      await fetchSuccessfully(pokemon);
      when(
        () => repository.getFormDetails(any()),
      ).thenAnswer((_) async => left(const UnexpectedFailure('nope')));

      bloc.add(SelectPokemonFormEvent(_megaForm));
      await pumpEventQueue();

      var state = bloc.state as PokemonBlocSuccess;
      expect(state.formFailure, isNotNull);
      expect(state.failedForm, isNotNull);

      bloc.add(ClearPokemonFormFailureEvent());
      await pumpEventQueue();

      state = bloc.state as PokemonBlocSuccess;
      expect(state.formFailure, isNull);
      expect(state.failedForm, isNull);
    });

    test(
      'reselecting the base form restores it without a network call',
      () async {
        final pokemon = buildPokemon(name: 'venusaur', forms: [_megaForm]);
        await fetchSuccessfully(pokemon);
        when(
          () => repository.getFormDetails(any()),
        ).thenAnswer((_) async => right(_megaDetails));

        bloc.add(SelectPokemonFormEvent(_megaForm));
        await pumpEventQueue();
        expect(
          (bloc.state as PokemonBlocSuccess).selectedFormDetails,
          _megaDetails,
        );

        bloc.add(
          SelectPokemonFormEvent(
            PokemonForm(name: pokemon.name, url: 'ignored'),
          ),
        );
        await pumpEventQueue();

        expect(
          (bloc.state as PokemonBlocSuccess).selectedFormDetails,
          PokemonFormDetails.fromPokemon(pokemon),
        );
        verify(() => repository.getFormDetails(any())).called(1);
      },
    );
  });

  group('retry and cached loading', () {
    test(
      'retrying fetch after failure successfully loads the Pokémon',
      () async {
        when(
          () => repository.getPokemon(any()),
        ).thenAnswer((_) async => left(const NetworkUnavailableFailure()));

        bloc.add(FetchPokemonEvent('pikachu'));
        await pumpEventQueue();

        expect(bloc.state, isA<PokemonBlocFailure>());
        expect(
          (bloc.state as PokemonBlocFailure).failure,
          isA<NetworkUnavailableFailure>(),
        );

        final pikachu = buildPokemon(id: 25, name: 'pikachu');
        when(
          () => repository.getPokemon(any()),
        ).thenAnswer((_) async => right(pikachu));

        bloc.add(FetchPokemonEvent('pikachu'));
        await pumpEventQueue();

        expect(bloc.state, isA<PokemonBlocSuccess>());
        expect((bloc.state as PokemonBlocSuccess).pokemon.name, 'pikachu');
      },
    );

    test('successfully loads cached Pokémon with stale indicator', () async {
      final cachedPokemon = buildPokemon(
        id: 25,
        name: 'pikachu',
        isStale: true,
      );
      when(
        () => repository.getPokemon(any()),
      ).thenAnswer((_) async => right(cachedPokemon));

      bloc.add(FetchPokemonEvent('pikachu'));
      await pumpEventQueue();

      expect(bloc.state, isA<PokemonBlocSuccess>());
      final success = bloc.state as PokemonBlocSuccess;
      expect(success.pokemon.name, 'pikachu');
      expect(success.pokemon.isStale, isTrue);
    });
  });
}
