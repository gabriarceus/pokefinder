import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pokefinder/l10n/app_localizations.dart';
import 'package:pokefinder/src/1_presentation/widgets/pokedex/pokedex_filter_bottom_sheet.dart';
import 'package:pokefinder/src/2_application/bloc/pokedex_bloc/pokedex_bloc.dart';
import 'package:pokefinder/src/3_domain/domain.dart';

class _MockPokedexBloc extends Mock implements PokedexBloc {}

void main() {
  late _MockPokedexBloc bloc;
  late StreamController<PokedexState> streamController;

  const sampleEntries = [
    PokemonIndexEntry(id: 1, name: 'bulbasaur', detailUrl: ''),
    PokemonIndexEntry(id: 4, name: 'charmander', detailUrl: ''),
    PokemonIndexEntry(id: 7, name: 'squirtle', detailUrl: ''),
  ];

  setUpAll(() {
    // PokedexEvent is sealed, so a real event doubles as the mocktail fallback.
    registerFallbackValue(const PokedexClearFiltersEvent());
  });

  setUp(() {
    bloc = _MockPokedexBloc();
    streamController = StreamController<PokedexState>.broadcast();
    when(() => bloc.stream).thenAnswer((_) => streamController.stream);
  });

  tearDown(() async {
    await streamController.close();
  });

  /// Gives the sheet a tall viewport so every section is laid out at once.
  void useTallScreen(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  Widget buildTestableWidget() {
    return MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: BlocProvider<PokedexBloc>.value(
          value: bloc,
          child: const PokedexFilterBottomSheet(),
        ),
      ),
    );
  }

  /// Hosts the sheet behind [PokedexFilterBottomSheet.show], so that its single
  /// close action really dismisses a route.
  Widget buildModalTestableWidget() {
    return BlocProvider<PokedexBloc>.value(
      value: bloc,
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => PokedexFilterBottomSheet.show(context),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
  }

  group('PokedexFilterBottomSheet', () {
    testWidgets('renders all sections: types, generation, and sort', (
      tester,
    ) async {
      useTallScreen(tester);

      when(() => bloc.state).thenReturn(const PokedexState());

      await tester.pumpWidget(buildTestableWidget());
      await tester.pump();

      expect(find.text('Filters'), findsOneWidget);
      expect(find.text('Types'), findsOneWidget);
      expect(find.text('Generation'), findsOneWidget);
      expect(find.text('Sort By'), findsOneWidget);
      expect(find.text('Fire'), findsOneWidget);
      expect(find.text('Water'), findsOneWidget);
      expect(find.text('Grass'), findsOneWidget);
      expect(find.text('All Generations'), findsOneWidget);
    });

    testWidgets(
      'toggling a type filter chip dispatches PokedexTypeFilterToggledEvent',
      (tester) async {
        when(() => bloc.state).thenReturn(const PokedexState());

        await tester.pumpWidget(buildTestableWidget());
        await tester.pump();

        await tester.tap(find.text('Fire'));
        await tester.pump();

        verify(
          () => bloc.add(const PokedexTypeFilterToggledEvent(PokemonType.fire)),
        ).called(1);
      },
    );

    testWidgets(
      'selecting a generation chip dispatches PokedexGenerationFilterChangedEvent',
      (tester) async {
        useTallScreen(tester);

        when(() => bloc.state).thenReturn(const PokedexState());

        await tester.pumpWidget(buildTestableWidget());
        await tester.pump();

        await tester.tap(find.text('Gen 1'));
        await tester.pump();

        verify(
          () => bloc.add(const PokedexGenerationFilterChangedEvent(1)),
        ).called(1);
      },
    );

    testWidgets(
      'selecting sort order chip dispatches PokedexSortOrderChangedEvent',
      (tester) async {
        useTallScreen(tester);

        when(() => bloc.state).thenReturn(const PokedexState());

        await tester.pumpWidget(buildTestableWidget());
        await tester.pump();

        await tester.tap(find.text('Name: A - Z'));
        await tester.pump();

        verify(
          () => bloc.add(
            const PokedexSortOrderChangedEvent(PokedexSortOrder.nameAscending),
          ),
        ).called(1);
      },
    );

    testWidgets(
      'reset button dispatches PokedexClearFiltersEvent when active filters exist',
      (tester) async {
        when(() => bloc.state).thenReturn(
          const PokedexState().copyWith(
            filters: PokedexFilters(selectedTypes: {PokemonType.fire}),
          ),
        );

        await tester.pumpWidget(buildTestableWidget());
        await tester.pump();

        await tester.tap(find.text('Reset'));
        await tester.pump();

        verify(() => bloc.add(const PokedexClearFiltersEvent())).called(1);
      },
    );

    testWidgets(
      'selecting form category chip dispatches PokedexFormFilterChangedEvent',
      (tester) async {
        useTallScreen(tester);

        when(() => bloc.state).thenReturn(const PokedexState());

        await tester.pumpWidget(buildTestableWidget());
        await tester.pump();

        expect(find.text('Forms'), findsOneWidget);
        expect(find.text('Mega Evolutions'), findsOneWidget);

        await tester.tap(find.text('Mega Evolutions'));
        await tester.pump();

        verify(
          () => bloc.add(
            const PokedexFormFilterChangedEvent(PokedexFormFilter.mega),
          ),
        ).called(1);
      },
    );

    testWidgets(
      'toggling cosmetic forms switch dispatches PokedexCosmeticToggleChangedEvent',
      (tester) async {
        useTallScreen(tester);

        when(() => bloc.state).thenReturn(const PokedexState());

        await tester.pumpWidget(buildTestableWidget());
        await tester.pump();

        final switchFinder = find.byType(Switch);
        expect(switchFinder, findsOneWidget);

        await tester.tap(switchFinder);
        await tester.pump();

        verify(
          () => bloc.add(const PokedexCosmeticToggleChangedEvent(true)),
        ).called(1);
      },
    );

    testWidgets(
      'the active filters badge counts the selected types and generations',
      (tester) async {
        useTallScreen(tester);

        when(() => bloc.state).thenReturn(
          const PokedexState().copyWith(
            filters: PokedexFilters(
              query: 'pika',
              selectedTypes: {PokemonType.fire, PokemonType.water},
              generation: 1,
            ),
          ),
        );

        await tester.pumpWidget(buildTestableWidget());
        await tester.pump();

        // The search text is not counted, the three filters are.
        expect(find.text('3'), findsOneWidget);
      },
    );

    testWidgets(
      'the single close action reports the result count and dismisses the sheet '
      'without applying anything',
      (tester) async {
        useTallScreen(tester);

        when(() => bloc.state).thenReturn(
          const PokedexState().copyWith(
            status: PokedexStatus.success,
            filteredEntries: sampleEntries,
          ),
        );

        await tester.pumpWidget(buildModalTestableWidget());
        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();

        expect(find.byType(PokedexFilterBottomSheet), findsOneWidget);
        expect(find.text('Show 3 results'), findsOneWidget);

        clearInteractions(bloc);
        await tester.tap(find.text('Show 3 results'));
        await tester.pumpAndSettle();

        expect(find.byType(PokedexFilterBottomSheet), findsNothing);
        // Filters already applied live: closing dispatches no event at all.
        verifyNever(() => bloc.add(any()));
      },
    );
  });
}
