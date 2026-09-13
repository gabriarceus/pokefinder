import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:pokefinder/l10n/app_localizations.dart';
import 'package:pokefinder/src/1_presentation/widgets/pokedex/pokemon_card.dart';
import 'package:pokefinder/src/3_domain/domain.dart';

void main() {
  Widget buildTestableWidget(
    Widget child, {
    Locale locale = const Locale('en'),
  }) {
    return MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: Center(child: child)),
    );
  }

  group('PokemonCard', () {
    testWidgets('renders number, name, and sprite image', (tester) async {
      await mockNetworkImagesFor(() async {
        const entry = PokemonIndexEntry(
          id: 25,
          name: 'pikachu',
          detailUrl: 'https://pokeapi.co/api/v2/pokemon/25/',
          types: [PokemonType.electric],
        );

        await tester.pumpWidget(
          buildTestableWidget(
            const SizedBox(
              width: 160,
              height: 180,
              child: PokemonCard(entry: entry),
            ),
          ),
        );

        expect(find.text('#025'), findsOneWidget);
        expect(find.text('Pikachu'), findsOneWidget);
        expect(find.text('Gen 1'), findsOneWidget);
        expect(find.text('Electric'), findsOneWidget);
        expect(find.byType(Image), findsOneWidget);
      });
    });

    testWidgets('triggers onTap callback when tapped', (tester) async {
      await mockNetworkImagesFor(() async {
        var tapped = false;
        const entry = PokemonIndexEntry(
          id: 1,
          name: 'bulbasaur',
          detailUrl: 'https://pokeapi.co/api/v2/pokemon/1/',
        );

        await tester.pumpWidget(
          buildTestableWidget(
            SizedBox(
              width: 160,
              height: 180,
              child: PokemonCard(entry: entry, onTap: () => tapped = true),
            ),
          ),
        );

        await tester.tap(find.byType(PokemonCard));
        await tester.pump();

        expect(tapped, isTrue);
      });
    });

    testWidgets('meets minimum 48x48 dp touch target requirement', (
      tester,
    ) async {
      await mockNetworkImagesFor(() async {
        const entry = PokemonIndexEntry(
          id: 4,
          name: 'charmander',
          detailUrl: '',
        );

        await tester.pumpWidget(
          buildTestableWidget(
            const SizedBox(
              width: 150,
              height: 160,
              child: PokemonCard(entry: entry),
            ),
          ),
        );

        final cardSize = tester.getSize(find.byType(PokemonCard));
        expect(cardSize.width, greaterThanOrEqualTo(48.0));
        expect(cardSize.height, greaterThanOrEqualTo(48.0));
      });
    });

    testWidgets(
      'exposes accessible semantics label with types and excludes children semantics',
      (tester) async {
        await mockNetworkImagesFor(() async {
          const entry = PokemonIndexEntry(
            id: 25,
            name: 'pikachu',
            detailUrl: '',
            types: [PokemonType.electric],
          );

          await tester.pumpWidget(
            buildTestableWidget(
              const SizedBox(
                width: 160,
                height: 180,
                child: PokemonCard(entry: entry),
              ),
            ),
          );

          final semanticsFinder = find.descendant(
            of: find.byType(PokemonCard),
            matching: find.byType(Semantics),
          );
          final semanticsWidget = tester.widget<Semantics>(
            semanticsFinder.first,
          );
          expect(semanticsWidget.properties.label, '#025, Pikachu, Electric');
          expect(semanticsWidget.properties.button, isTrue);
          expect(semanticsWidget.excludeSemantics, isTrue);
        });
      },
    );

    testWidgets(
      'renders form badge and canonical parent dex number for alternate form',
      (tester) async {
        await mockNetworkImagesFor(() async {
          const megaCharizard = PokemonIndexEntry(
            id: 10034,
            name: 'charizard-mega-x',
            detailUrl: '',
            parentSpeciesId: 6,
            parentSpeciesName: 'charizard',
            formCategory: PokemonFormCategory.mega,
            types: [PokemonType.fire, PokemonType.dragon],
            introductionGeneration: 6,
            speciesGeneration: 1,
          );

          await tester.pumpWidget(
            buildTestableWidget(
              const SizedBox(
                width: 160,
                height: 180,
                child: PokemonCard(entry: megaCharizard),
              ),
            ),
          );

          expect(find.text('#0006'), findsOneWidget);
          expect(find.text('Mega Charizard X'), findsOneWidget);
          expect(find.text('MEGA X'), findsOneWidget);
        });
      },
    );

    testWidgets(
      'renders subtle form indicator on base card with alternate forms',
      (tester) async {
        await mockNetworkImagesFor(() async {
          const baseCharizard = PokemonIndexEntry(
            id: 6,
            name: 'charizard',
            detailUrl: '',
            types: [PokemonType.fire, PokemonType.flying],
            hasAlternateForms: true,
            availableFormCategories: [PokemonFormCategory.mega],
          );

          await tester.pumpWidget(
            buildTestableWidget(
              const SizedBox(
                width: 160,
                height: 180,
                child: PokemonCard(entry: baseCharizard),
              ),
            ),
          );

          expect(find.text('#006'), findsOneWidget);
          expect(find.text('Charizard'), findsOneWidget);
          expect(find.text('⚡ Mega'), findsOneWidget);

          final semanticsFinder = find.descendant(
            of: find.byType(PokemonCard),
            matching: find.byType(Semantics),
          );
          final semanticsWidget = tester.widget<Semantics>(
            semanticsFinder.first,
          );
          expect(
            semanticsWidget.properties.label,
            '#006, Charizard, alternate forms available, Fire, Flying',
          );
        });
      },
    );

    testWidgets(
      'renders localized base card form indicator in Italian and announces localized semantics',
      (tester) async {
        await mockNetworkImagesFor(() async {
          const baseVulpix = PokemonIndexEntry(
            id: 37,
            name: 'vulpix',
            detailUrl: '',
            types: [PokemonType.fire],
            hasAlternateForms: true,
            availableFormCategories: [PokemonFormCategory.regional],
          );

          await tester.pumpWidget(
            buildTestableWidget(
              const SizedBox(
                width: 160,
                height: 180,
                child: PokemonCard(entry: baseVulpix),
              ),
              locale: const Locale('it'),
            ),
          );

          expect(find.text('#037'), findsOneWidget);
          expect(find.text('Vulpix'), findsOneWidget);
          expect(find.text('🌍 Regionali'), findsOneWidget);

          final semanticsFinder = find.descendant(
            of: find.byType(PokemonCard),
            matching: find.byType(Semantics),
          );
          final semanticsWidget = tester.widget<Semantics>(
            semanticsFinder.first,
          );
          expect(
            semanticsWidget.properties.label,
            '#037, Vulpix, forme alternative disponibili, Fuoco',
          );
        });
      },
    );
  });
}
