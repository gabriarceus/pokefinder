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

  setUp(() {
    bloc = _MockPokedexBloc();
    streamController = StreamController<PokedexState>.broadcast();
    when(() => bloc.stream).thenAnswer((_) => streamController.stream);
  });

  tearDown(() async {
    await streamController.close();
  });

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

  group('PokedexFilterBottomSheet', () {
    testWidgets('renders all sections: types, generation, and sort', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      when(() => bloc.state).thenReturn(PokedexState.initial());

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
        when(() => bloc.state).thenReturn(PokedexState.initial());

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
        tester.view.physicalSize = const Size(800, 1400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        when(() => bloc.state).thenReturn(PokedexState.initial());

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
        tester.view.physicalSize = const Size(800, 1400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        when(() => bloc.state).thenReturn(PokedexState.initial());

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
          PokedexState.initial().copyWith(selectedTypes: {PokemonType.fire}),
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
        tester.view.physicalSize = const Size(800, 1400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        when(() => bloc.state).thenReturn(PokedexState.initial());

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
        tester.view.physicalSize = const Size(800, 1400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        when(() => bloc.state).thenReturn(PokedexState.initial());

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
  });
}
