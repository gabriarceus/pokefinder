import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:en_logger/en_logger.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pokefinder/src/2_application/bloc/detail_bloc/detail_bloc.dart';
import 'package:pokefinder/src/3_domain/cancellation_token.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon_type.dart';
import 'package:pokefinder/src/3_domain/failures/pokemon_failure.dart';
import 'package:pokefinder/src/3_domain/usecases/get_pokemon_encounters_usecase.dart';
import 'package:pokefinder/src/3_domain/usecases/get_pokemon_form_details_usecase.dart';
import 'package:pokefinder/src/3_domain/usecases/get_pokemon_usecase.dart';
import 'package:pokefinder/src/3_domain/value_objects/pokemon_name.dart';

import '../fixtures/pokemon_fixture.dart';

class _MockGetPokemonUseCase extends Mock implements GetPokemonUseCase {}

class _MockGetPokemonEncountersUseCase extends Mock
    implements GetPokemonEncountersUseCase {}

class _MockGetPokemonFormDetailsUseCase extends Mock
    implements GetPokemonFormDetailsUseCase {}

class _MockEnLogger extends Mock implements EnLogger {}

const _megaForm = PokemonForm(
  name: 'venusaur-mega',
  url: 'https://pokeapi.co/api/v2/pokemon-form/10033/',
);

const _megaDetails = PokemonFormDetails(
  name: 'venusaur-mega',
  type1: PokemonType.grass,
  type2: PokemonType.poison,
  typeImage1: 'grass.png',
  typeImage2: 'poison.png',
  spriteDefault: 'mega.png',
  spriteShiny: 'mega-shiny.png',
  artworkDefault: 'mega-art.png',
  artworkShiny: 'mega-art-shiny.png',
);

const _encounters = [
  PokemonEncounter(
    locationAreaName: 'Viridian Forest',
    rawLocationAreaName: 'viridian-forest',
    versions: ['red'],
  ),
];

void main() {
  setUpAll(() {
    registerFallbackValue(PokemonName('placeholder'));
    registerFallbackValue(CancellationToken());
  });

  late _MockGetPokemonUseCase getPokemon;
  late _MockGetPokemonEncountersUseCase getEncounters;
  late _MockGetPokemonFormDetailsUseCase getFormDetails;
  late PokemonBloc bloc;

  setUp(() {
    getPokemon = _MockGetPokemonUseCase();
    getEncounters = _MockGetPokemonEncountersUseCase();
    getFormDetails = _MockGetPokemonFormDetailsUseCase();
    bloc = PokemonBloc(
      getPokemon,
      getEncounters,
      getFormDetails,
      _MockEnLogger(),
    );

    when(
      () => getEncounters(any(), cancelToken: any(named: 'cancelToken')),
    ).thenAnswer((_) async => right(const []));
  });

  tearDown(() => bloc.close());

  /// Drives a successful fetch to completion and returns the resulting state.
  Future<PokemonBlocSuccess> fetchSuccessfully(Pokemon pokemon) async {
    when(
      () => getPokemon(any(), cancelToken: any(named: 'cancelToken')),
    ).thenAnswer((_) async => right(pokemon));
    bloc.add(FetchPokemonEvent(pokemon.name));
    await pumpEventQueue();
    return bloc.state as PokemonBlocSuccess;
  }

  group('fetching a Pokémon', () {
    test('a blank name is rejected without hitting the use case', () async {
      bloc.add(FetchPokemonEvent('   '));
      await pumpEventQueue();

      expect(bloc.state, isA<PokemonBlocInitial>());
      verifyNever(() => getPokemon(any()));
    });

    test('emits loading then failure when the fetch fails', () async {
      when(
        () => getPokemon(any(), cancelToken: any(named: 'cancelToken')),
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
          spriteFrontShiny: 'shiny.png',
          officialArtworkDefault: 'art.png',
        );
        when(
          () => getPokemon(any(), cancelToken: any(named: 'cancelToken')),
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
      },
    );

    test('loads encounters in the background after the Pokémon', () async {
      when(
        () => getEncounters(any(), cancelToken: any(named: 'cancelToken')),
      ).thenAnswer((_) async => right(_encounters));

      final state = await fetchSuccessfully(buildPokemon());

      expect(state.isLoadingEncounters, isFalse);
      expect(state.encounters, _encounters);
      expect(state.encountersFailure, isNull);
      verify(
        () => getEncounters(
          'https://pokeapi.co/api/v2/pokemon/1/encounters',
          cancelToken: any(named: 'cancelToken'),
        ),
      ).called(1);
    });

    test(
      'an encounters failure is surfaced without losing the Pokémon',
      () async {
        when(
          () => getEncounters(any(), cancelToken: any(named: 'cancelToken')),
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
        when(
          () => getEncounters(any(), cancelToken: any(named: 'cancelToken')),
        ).thenAnswer((_) {
          encountersCall++;
          return encountersCall == 1
              ? staleEncounters.future
              : Future.value(right(const []));
        });

        when(
          () => getPokemon(any(), cancelToken: any(named: 'cancelToken')),
        ).thenAnswer((_) async => right(first));
        bloc.add(FetchPokemonEvent('bulbasaur'));
        await pumpEventQueue();

        when(
          () => getPokemon(any(), cancelToken: any(named: 'cancelToken')),
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
  });

  group('retrying encounters', () {
    test('retries encounters loading after a failure', () async {
      when(
        () => getEncounters(any(), cancelToken: any(named: 'cancelToken')),
      ).thenAnswer((_) async => left(const NetworkUnavailableFailure()));

      final state = await fetchSuccessfully(buildPokemon(name: 'venusaur'));
      expect(state.encountersFailure, const NetworkUnavailableFailure());

      when(
        () => getEncounters(any(), cancelToken: any(named: 'cancelToken')),
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
      verifyNever(() => getFormDetails(any()));
    });

    test('loads the details of a non-default form', () async {
      await fetchSuccessfully(
        buildPokemon(name: 'venusaur', forms: [_megaForm]),
      );
      when(
        () => getFormDetails(
          _megaForm.url,
          cancelToken: any(named: 'cancelToken'),
        ),
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
    });

    test(
      'a form failure is surfaced and the previous selection is kept, recording failedForm',
      () async {
        final pokemon = buildPokemon(name: 'venusaur', forms: [_megaForm]);
        await fetchSuccessfully(pokemon);
        when(
          () => getFormDetails(any(), cancelToken: any(named: 'cancelToken')),
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
        () => getFormDetails(any(), cancelToken: any(named: 'cancelToken')),
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
          () => getFormDetails(any(), cancelToken: any(named: 'cancelToken')),
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
        verify(
          () => getFormDetails(any(), cancelToken: any(named: 'cancelToken')),
        ).called(1);
      },
    );
  });

  group('cancellation', () {
    test('cancels in-flight cancelToken when closed', () async {
      CancellationToken? capturedToken;
      final completer = Completer<Either<PokemonFailure, Pokemon>>();

      when(
        () => getPokemon(any(), cancelToken: any(named: 'cancelToken')),
      ).thenAnswer((invocation) {
        capturedToken =
            invocation.namedArguments[#cancelToken] as CancellationToken?;
        return completer.future;
      });

      bloc.add(FetchPokemonEvent('bulbasaur'));
      await pumpEventQueue();

      expect(capturedToken, isNotNull);
      expect(capturedToken!.isCancelled, isFalse);

      await bloc.close();

      expect(capturedToken!.isCancelled, isTrue);
      expect(capturedToken!.reason, contains('closed'));
    });

    test(
      'cancels previous in-flight token when superseded by new event and avoids emitting failure',
      () async {
        final capturedTokens = <CancellationToken>[];
        final completer1 = Completer<Either<PokemonFailure, Pokemon>>();
        final completer2 = Completer<Either<PokemonFailure, Pokemon>>();

        when(
          () => getPokemon(any(), cancelToken: any(named: 'cancelToken')),
        ).thenAnswer((invocation) {
          final token =
              invocation.namedArguments[#cancelToken] as CancellationToken?;
          if (token != null) capturedTokens.add(token);
          return capturedTokens.length == 1
              ? completer1.future
              : completer2.future;
        });

        bloc.add(FetchPokemonEvent('bulbasaur'));
        await pumpEventQueue();

        expect(capturedTokens.length, 1);
        expect(capturedTokens[0].isCancelled, isFalse);

        bloc.add(FetchPokemonEvent('ivysaur'));
        await pumpEventQueue();

        expect(capturedTokens.length, 2);
        expect(capturedTokens[0].isCancelled, isTrue);
        expect(capturedTokens[0].reason, contains('Superseded'));
        expect(capturedTokens[1].isCancelled, isFalse);

        // Complete first (superseded) request with cancellation failure
        completer1.complete(left(const RequestCancelledFailure()));
        await pumpEventQueue();

        // Ensure no failure state was emitted (state remains loading)
        expect(bloc.state, isA<PokemonBlocLoading>());

        // Complete second request successfully
        final expectedPokemon = buildPokemon(name: 'ivysaur');
        completer2.complete(right(expectedPokemon));
        await pumpEventQueue();

        expect(bloc.state, isA<PokemonBlocSuccess>());
        expect(
          (bloc.state as PokemonBlocSuccess).pokemon.name,
          expectedPokemon.name,
        );
      },
    );
  });
}
