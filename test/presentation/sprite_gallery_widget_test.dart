import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:pokefinder/l10n/app_localizations.dart';
import 'package:pokefinder/src/1_presentation/widgets/detail/sprite_gallery_widget.dart';

import '../fixtures/pokemon_fixture.dart';

Widget _buildHarness({
  required Widget child,
  Locale locale = const Locale('en'),
}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: locale,
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

void main() {
  group('SpriteGalleryWidget', () {
    testWidgets('renders the available variants with localized labels', (
      tester,
    ) async {
      await mockNetworkImagesFor(() async {
        final pokemon = buildPokemon(
          sprite: 'front.png',
          spriteBackDefault: 'back.png',
          spriteFrontShiny: 'front-shiny.png',
          officialArtworkDefault: 'art.png',
          homeDefault: 'home.png',
        );

        await tester.pumpWidget(
          _buildHarness(
            child: SpriteGalleryWidget(
              pokemon: pokemon,
              textColor: Colors.black,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Sprite Gallery'), findsOneWidget);
        expect(find.text('Official artwork'), findsOneWidget);
        expect(find.text('Front (default)'), findsOneWidget);
        expect(find.text('Back (default)'), findsOneWidget);
        expect(find.text('Front (shiny)'), findsOneWidget);
        expect(find.text('Home (default)'), findsOneWidget);
        // Missing optionals are omitted, not blank holes.
        expect(find.text('Front (female)'), findsNothing);
      });
    });

    testWidgets('empty payload renders a placeholder without crashing', (
      tester,
    ) async {
      await mockNetworkImagesFor(() async {
        final pokemon = buildPokemon(sprite: '');

        await tester.pumpWidget(
          _buildHarness(
            child: SpriteGalleryWidget(
              pokemon: pokemon,
              textColor: Colors.black,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Sprite Gallery'), findsOneWidget);
        expect(find.text('No data available'), findsOneWidget);
        expect(find.byIcon(Icons.image_not_supported_outlined), findsOneWidget);
      });
    });

    testWidgets('failed images render placeholder icons, never raw text', (
      tester,
    ) async {
      await mockNetworkImagesFor(() async {
        final pokemon = buildPokemon(
          sprite: 'https://invalid/front.png',
          officialArtworkDefault: 'https://invalid/art.png',
        );

        await tester.pumpWidget(
          _buildHarness(
            child: SpriteGalleryWidget(
              pokemon: pokemon,
              textColor: Colors.black,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Every network image must carry an errorBuilder that resolves to a
        // placeholder icon (no raw emoticons, no blank holes).
        final images = tester.widgetList<Image>(find.byType(Image)).toList();
        expect(images, isNotEmpty);
        final context = tester.element(find.byType(SpriteGalleryWidget));
        for (final image in images) {
          expect(image.errorBuilder, isNotNull);
          final errorWidget = image.errorBuilder!(
            context,
            Exception('network failure'),
            null,
          );
          expect(errorWidget, isA<Icon>());
          expect((errorWidget as Icon).icon, Icons.broken_image_outlined);
        }
        expect(find.textContaining(':('), findsNothing);
      });
    });

    testWidgets('semantics announce variant names', (tester) async {
      await mockNetworkImagesFor(() async {
        final pokemon = buildPokemon(
          sprite: 'front.png',
          officialArtworkDefault: 'art.png',
        );

        await tester.pumpWidget(
          _buildHarness(
            child: SpriteGalleryWidget(
              pokemon: pokemon,
              textColor: Colors.black,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.bySemanticsLabel('Official artwork'), findsOneWidget);
        expect(find.bySemanticsLabel('Front (default)'), findsOneWidget);
      });
    });

    testWidgets('tapping a variant opens a preview dialog', (tester) async {
      await mockNetworkImagesFor(() async {
        final pokemon = buildPokemon(
          sprite: 'front.png',
          officialArtworkDefault: 'art.png',
        );

        await tester.pumpWidget(
          _buildHarness(
            child: SpriteGalleryWidget(
              pokemon: pokemon,
              textColor: Colors.black,
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Official artwork'));
        await tester.pumpAndSettle();

        expect(find.byType(Dialog), findsOneWidget);
        expect(find.byType(CloseButton), findsOneWidget);

        await tester.tap(find.byType(CloseButton));
        await tester.pumpAndSettle();
        expect(find.byType(Dialog), findsNothing);
      });
    });

    testWidgets('preview dialog does not overflow on compact landscape', (
      tester,
    ) async {
      await mockNetworkImagesFor(() async {
        tester.view.physicalSize = const Size(568, 320);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final pokemon = buildPokemon(
          sprite: 'front.png',
          officialArtworkDefault: 'art.png',
        );

        await tester.pumpWidget(
          _buildHarness(
            child: SpriteGalleryWidget(
              pokemon: pokemon,
              textColor: Colors.black,
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Official artwork'));
        await tester.pumpAndSettle();

        expect(find.byType(Dialog), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });

    testWidgets('localizes variant labels in Italian', (tester) async {
      await mockNetworkImagesFor(() async {
        final pokemon = buildPokemon(
          sprite: 'front.png',
          officialArtworkDefault: 'art.png',
        );

        await tester.pumpWidget(
          _buildHarness(
            locale: const Locale('it'),
            child: SpriteGalleryWidget(
              pokemon: pokemon,
              textColor: Colors.black,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Galleria Sprite'), findsOneWidget);
        expect(find.text('Artwork ufficiale'), findsOneWidget);
        expect(find.text('Fronte (normale)'), findsOneWidget);
      });
    });
  });
}
