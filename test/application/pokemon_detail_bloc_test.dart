import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:en_logger/en_logger.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pokefinder/src/2_application/bloc/detail_bloc/detail_bloc.dart';
import 'package:pokefinder/src/2_application/helpers/log_sanitizer.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon_form_category.dart';
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

final _megaPokemon = buildPokemon(
  id: 10033,
  name: 'venusaur-mega',
  type1: PokemonType.grass,
  type2: PokemonType.poison,
  sprite: 'mega.png',
  speciesName: 'venusaur',
  weight: 1555,
  height: 24,
  cry: 'mega.ogg',
  stats: [80, 100, 123, 122, 120, 80],
  abilities: [PokemonAbility(name: 'thick-fat', isHidden: false)],
  locationAreaEncounters: 'mega/encounters',
  sprites: PokemonSprites(
    frontShiny: 'mega-shiny.png',
    artworkDefault: 'mega-art.png',
    artworkShiny: 'mega-art-shiny.png',
  ),
);

final _megaDetails = PokemonFormDetails.fromPokemon(_megaPokemon);

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
  Future<PokemonDetailSuccess> fetchSuccessfully(Pokemon pokemon) async {
    when(
      () => repository.getPokemon(
        any(
          that: predicate<PokemonName>(
            (name) => name.rightOrCrash() == pokemon.name,
          ),
        ),
      ),
    ).thenAnswer((_) async => right(pokemon));
    bloc.add(FetchPokemonEvent(pokemon.name));
    await pumpEventQueue();
    return bloc.state as PokemonDetailSuccess;
  }

  group('fetching a Pokémon', () {
    test('fetch logs follow the query sanitizer policy', () async {
      expect(
        sanitizeQueryForLog('distinctive-nonexistent-name', isRelease: true),
        '[REDACTED]',
      );
      when(
        () => repository.getPokemon(any()),
      ).thenAnswer((_) async => left(const PokemonNotFoundFailure()));
      bloc.add(FetchPokemonEvent('distinctive-nonexistent-name'));
      await pumpEventQueue();
      verify(
        () => logger.info(
          'Fetching data for Pokemon: ${sanitizeQueryForLog('distinctive-nonexistent-name')}',
          prefix: 'DetailBloc',
        ),
      ).called(1);
    });
    test('a blank name is rejected without hitting the repository', () async {
      bloc.add(FetchPokemonEvent('   '));
      await pumpEventQueue();

      expect(bloc.state, isA<PokemonDetailInitial>());
      verifyNever(() => repository.getPokemon(any()));
    });

    test('emits loading then failure when the fetch fails', () async {
      when(
        () => repository.getPokemon(any()),
      ).thenAnswer((_) async => left(const BadRequestFailure()));

      final emitted = <PokemonDetailState>[];
      final subscription = bloc.stream.listen(emitted.add);

      bloc.add(FetchPokemonEvent('missingno'));
      await pumpEventQueue();
      await subscription.cancel();

      expect(emitted, [
        PokemonDetailLoading(),
        PokemonDetailFailure(const BadRequestFailure()),
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

        final emitted = <PokemonDetailState>[];
        final subscription = bloc.stream.listen(emitted.add);

        bloc.add(FetchPokemonEvent('venusaur'));
        await pumpEventQueue();
        await subscription.cancel();

        expect(emitted.first, PokemonDetailLoading());
        final firstSuccess = emitted[1] as PokemonDetailSuccess;
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
        // Lists render the high-resolution artwork, never the pixel sprite.
        expect(firstSuccess.summary.spriteUrl, 'art.png');
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

        final state = bloc.state as PokemonDetailSuccess;
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
        final emittedAfterIvysaur = <PokemonDetailState>[];
        final subscription = bloc.stream.listen(emittedAfterIvysaur.add);

        staleFetch.complete(left(const NetworkUnavailableFailure()));
        await pumpEventQueue();
        await subscription.cancel();

        expect(emittedAfterIvysaur, isEmpty);
        final state = bloc.state as PokemonDetailSuccess;
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

      final updatedState = bloc.state as PokemonDetailSuccess;
      expect(updatedState.isLoadingEncounters, isFalse);
      expect(updatedState.encounters, _encounters);
      expect(updatedState.encountersFailure, isNull);
    });
  });

  group('switching form', () {
    test('obsolete switches do not replace the latest selection', () async {
      final base = buildPokemon(id: 3, name: 'venusaur');
      await fetchSuccessfully(base);
      final pending = Completer<Either<PokemonFailure, Pokemon>>();
      when(
        () => repository.getPokemon(
          any(
            that: predicate<PokemonName>(
              (name) => name.rightOrCrash() == _megaForm.name,
            ),
          ),
        ),
      ).thenAnswer((_) => pending.future);
      bloc.add(SelectPokemonFormEvent(_megaForm));
      await pumpEventQueue();
      bloc.add(
        SelectPokemonFormEvent(PokemonForm(name: base.name, url: 'base')),
      );
      await pumpEventQueue();
      pending.complete(right(_megaPokemon));
      await pumpEventQueue();
      final state = bloc.state as PokemonDetailSuccess;
      expect(state.pokemon, base);
      expect(state.isLoadingForm, isFalse);
      expect(state.formFailure, isNull);
    });

    test('a failed switch retains full detail and can be retried', () async {
      final base = buildPokemon(id: 3, name: 'venusaur');
      await fetchSuccessfully(base);
      when(
        () => repository.getPokemon(
          any(
            that: predicate<PokemonName>(
              (name) => name.rightOrCrash() == _megaForm.name,
            ),
          ),
        ),
      ).thenAnswer((_) async => left(const NetworkUnavailableFailure()));
      bloc.add(SelectPokemonFormEvent(_megaForm));
      await pumpEventQueue();
      expect((bloc.state as PokemonDetailSuccess).pokemon, base);
      expect((bloc.state as PokemonDetailSuccess).summary.id, 3);
      when(
        () => repository.getPokemon(
          any(
            that: predicate<PokemonName>(
              (name) => name.rightOrCrash() == _megaForm.name,
            ),
          ),
        ),
      ).thenAnswer((_) async => right(_megaPokemon));
      bloc.add(SelectPokemonFormEvent(_megaForm));
      await pumpEventQueue();
      final state = bloc.state as PokemonDetailSuccess;
      expect(state.pokemon, _megaPokemon);
      expect(state.formFailure, isNull);
      expect(state.failedForm, isNull);
      verify(() => repository.getEncounters('mega/encounters')).called(1);
    });

    test(
      'a form switch discards old encounters and their late failure',
      () async {
        final pending =
            Completer<Either<PokemonFailure, List<PokemonEncounter>>>();
        final base = buildPokemon(id: 3, name: 'venusaur');
        when(
          () => repository.getEncounters(base.locationAreaEncounters),
        ).thenAnswer((_) => pending.future);
        await fetchSuccessfully(base);
        when(
          () => repository.getPokemon(
            any(
              that: predicate<PokemonName>(
                (name) => name.rightOrCrash() == _megaForm.name,
              ),
            ),
          ),
        ).thenAnswer((_) async => right(_megaPokemon));
        bloc.add(SelectPokemonFormEvent(_megaForm));
        await pumpEventQueue();
        pending.complete(left(const NetworkUnavailableFailure()));
        await pumpEventQueue();
        final state = bloc.state as PokemonDetailSuccess;
        expect(state.pokemon, _megaPokemon);
        expect(state.encounters, isEmpty);
        expect(state.encountersFailure, isNull);
        expect(state.isLoadingEncounters, isFalse);
      },
    );

    test('a new fetch supersedes a pending form switch', () async {
      await fetchSuccessfully(buildPokemon(id: 3, name: 'venusaur'));
      final pending = Completer<Either<PokemonFailure, Pokemon>>();
      when(
        () => repository.getPokemon(
          any(
            that: predicate<PokemonName>(
              (name) => name.rightOrCrash() == _megaForm.name,
            ),
          ),
        ),
      ).thenAnswer((_) => pending.future);
      bloc.add(SelectPokemonFormEvent(_megaForm));
      await pumpEventQueue();
      final other = buildPokemon(id: 25, name: 'pikachu');
      await fetchSuccessfully(other);
      pending.complete(left(const NetworkUnavailableFailure()));
      await pumpEventQueue();
      final state = bloc.state as PokemonDetailSuccess;
      expect(state.pokemon, other);
      expect(state.formFailure, isNull);
    });
    test('is ignored before a Pokémon has been loaded', () async {
      bloc.add(SelectPokemonFormEvent(_megaForm));
      await pumpEventQueue();

      expect(bloc.state, isA<PokemonDetailInitial>());
      verifyNever(() => repository.getPokemon(any()));
    });

    test('loads the details of a non-default form', () async {
      await fetchSuccessfully(
        buildPokemon(name: 'venusaur', forms: [_megaForm]),
      );
      when(
        () => repository.getPokemon(
          any(
            that: predicate<PokemonName>(
              (name) => name.rightOrCrash() == _megaForm.name,
            ),
          ),
        ),
      ).thenAnswer((_) async => right(_megaPokemon));

      final emitted = <PokemonDetailSuccess>[];
      final subscription = bloc.stream.cast<PokemonDetailSuccess>().listen(
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
      // Keyed by the form's own id, so favouriting a form never replaces the
      // base species entry.
      expect(emitted.last.summary.id, 10033);
      expect(emitted.last.summary.spriteUrl, 'mega-art.png');
      expect(emitted.last.pokemon, _megaPokemon);
      expect(emitted.last.summary.parentSpeciesId, 3);
      expect(emitted.last.summary.formCategory, PokemonFormCategory.mega);
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
          () => repository.getPokemon(
            any(
              that: predicate<PokemonName>(
                (name) => name.rightOrCrash() == _megaForm.name,
              ),
            ),
          ),
        ).thenAnswer((_) async => left(const UnexpectedFailure('nope')));

        bloc.add(SelectPokemonFormEvent(_megaForm));
        await pumpEventQueue();

        final state = bloc.state as PokemonDetailSuccess;
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
        () => repository.getPokemon(
          any(
            that: predicate<PokemonName>(
              (name) => name.rightOrCrash() == _megaForm.name,
            ),
          ),
        ),
      ).thenAnswer((_) async => left(const UnexpectedFailure('nope')));

      bloc.add(SelectPokemonFormEvent(_megaForm));
      await pumpEventQueue();

      var state = bloc.state as PokemonDetailSuccess;
      expect(state.formFailure, isNotNull);
      expect(state.failedForm, isNotNull);

      bloc.add(ClearPokemonFormFailureEvent());
      await pumpEventQueue();

      state = bloc.state as PokemonDetailSuccess;
      expect(state.formFailure, isNull);
      expect(state.failedForm, isNull);
    });

    test('reselecting the base form reloads its full detail', () async {
      final pokemon = buildPokemon(name: 'venusaur', forms: [_megaForm]);
      await fetchSuccessfully(pokemon);
      when(
        () => repository.getPokemon(
          any(
            that: predicate<PokemonName>(
              (name) => name.rightOrCrash() == _megaForm.name,
            ),
          ),
        ),
      ).thenAnswer((_) async => right(_megaPokemon));

      bloc.add(SelectPokemonFormEvent(_megaForm));
      await pumpEventQueue();
      expect(
        (bloc.state as PokemonDetailSuccess).selectedFormDetails,
        _megaDetails,
      );

      bloc.add(
        SelectPokemonFormEvent(PokemonForm(name: pokemon.name, url: 'ignored')),
      );
      await pumpEventQueue();

      expect(
        (bloc.state as PokemonDetailSuccess).selectedFormDetails,
        PokemonFormDetails.fromPokemon(pokemon),
      );
      verify(
        () => repository.getPokemon(
          any(
            that: predicate<PokemonName>(
              (name) => name.rightOrCrash() == _megaForm.name,
            ),
          ),
        ),
      ).called(1);
    });
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

        expect(bloc.state, isA<PokemonDetailFailure>());
        expect(
          (bloc.state as PokemonDetailFailure).failure,
          isA<NetworkUnavailableFailure>(),
        );

        final pikachu = buildPokemon(id: 25, name: 'pikachu');
        when(
          () => repository.getPokemon(any()),
        ).thenAnswer((_) async => right(pikachu));

        bloc.add(FetchPokemonEvent('pikachu'));
        await pumpEventQueue();

        expect(bloc.state, isA<PokemonDetailSuccess>());
        expect((bloc.state as PokemonDetailSuccess).pokemon.name, 'pikachu');
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

      expect(bloc.state, isA<PokemonDetailSuccess>());
      final success = bloc.state as PokemonDetailSuccess;
      expect(success.pokemon.name, 'pikachu');
      expect(success.pokemon.isStale, isTrue);
    });
  });
}
