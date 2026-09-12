import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:pokefinder/bootstrap.dart';
import 'package:pokefinder/l10n/app_localizations.dart';
import 'package:pokefinder/src/1_presentation/pages/detail/detail_page.dart';
import 'package:pokefinder/src/1_presentation/pages/home/home_page.dart';
import 'package:pokefinder/src/1_presentation/router/app_router.dart';
import 'package:pokefinder/src/1_presentation/widgets/home/pokeball_widget.dart';
import 'package:pokefinder/src/1_presentation/widgets/home/poke_text_field.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon_index_entry.dart';
import 'package:pokefinder/src/3_domain/failures/pokemon_failure.dart';

void main() {
  setUpAll(() async {
    await configureDependencies('mock');
  });

  group('PokeTextField', () {
    late TextEditingController controller;
    late FocusNode focusNode;
    late List<String> reportedInputs;

    setUp(() {
      controller = TextEditingController();
      focusNode = FocusNode();
      reportedInputs = [];
    });

    tearDown(() {
      controller.dispose();
      focusNode.dispose();
    });

    Future<void> pumpField(
      WidgetTester tester,
      List<String> allNames, {
      PokemonFailure? nameIndexFailure,
      VoidCallback? onRetryIndex,
    }) {
      return tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: PokeTextField(
              controller: controller,
              focusNode: focusNode,
              allEntries: allNames
                  .map(
                    (name) =>
                        PokemonIndexEntry(id: 1, name: name, detailUrl: ''),
                  )
                  .toList(),
              onChanged: reportedInputs.add,
              nameIndexFailure: nameIndexFailure,
              onRetryIndex: onRetryIndex,
            ),
          ),
        ),
      );
    }

    /// Names shown in the suggestion overlay, excluding the field's own text.
    List<String> visibleSuggestions() => find
        .descendant(of: find.byType(ListView), matching: find.byType(Text))
        .evaluate()
        .map((element) => (element.widget as Text).data!)
        .toList();

    testWidgets('reports every keystroke to the caller', (tester) async {
      await pumpField(tester, const []);

      await tester.enterText(find.byType(TextField), 'Pikachu');

      expect(controller.text, 'Pikachu');
      expect(reportedInputs.last, 'Pikachu');
    });

    testWidgets('shows no suggestions below the two-character threshold', (
      tester,
    ) async {
      await pumpField(tester, const ['pikachu', 'pidgey']);

      await tester.enterText(find.byType(TextField), 'p');
      await tester.pumpAndSettle();

      expect(find.byType(ListView), findsNothing);
    });

    testWidgets('suggests prefix matches case-insensitively', (tester) async {
      await pumpField(tester, const ['pikachu', 'pidgey', 'raichu']);

      await tester.enterText(find.byType(TextField), 'PI');
      await tester.pumpAndSettle();

      expect(visibleSuggestions(), ['pikachu', 'pidgey']);
    });

    testWidgets('caps the suggestion list at five entries', (tester) async {
      await pumpField(tester, List.generate(10, (i) => 'pika$i'));

      await tester.enterText(find.byType(TextField), 'pika');
      await tester.pumpAndSettle();

      expect(visibleSuggestions(), hasLength(5));
    });

    testWidgets('tapping a suggestion commits it to the field and the caller', (
      tester,
    ) async {
      await pumpField(tester, const ['pikachu', 'pidgey']);

      await tester.enterText(find.byType(TextField), 'pi');
      await tester.pumpAndSettle();
      await tester.tap(find.text('pidgey'));
      await tester.pumpAndSettle();

      expect(controller.text, 'pidgey');
      expect(reportedInputs.last, 'pidgey');
    });

    testWidgets('suggestion items meet minimum 48x48 dp touch target', (
      tester,
    ) async {
      await pumpField(tester, const ['pikachu', 'pidgey']);

      await tester.enterText(find.byType(TextField), 'pi');
      await tester.pumpAndSettle();

      final suggestionFinder = find.widgetWithText(InkWell, 'pikachu');
      expect(suggestionFinder, findsOneWidget);
      final size = tester.getSize(suggestionFinder);
      expect(size.height, greaterThanOrEqualTo(48.0));
      expect(size.width, greaterThanOrEqualTo(48.0));
    });

    testWidgets(
      'renders sync problem icon and triggers retry when index fails',
      (tester) async {
        var retried = false;
        await pumpField(
          tester,
          const [],
          nameIndexFailure: const NetworkUnavailableFailure(),
          onRetryIndex: () => retried = true,
        );

        final iconFinder = find.byIcon(Icons.sync_problem_rounded);
        expect(iconFinder, findsOneWidget);

        await tester.tap(iconFinder);
        await tester.pumpAndSettle();

        expect(retried, isTrue);
      },
    );

    testWidgets('suggests prefix matches when query has leading whitespace', (
      tester,
    ) async {
      await pumpField(tester, const ['pikachu', 'pidgey', 'raichu']);

      await tester.enterText(find.byType(TextField), '   pi');
      await tester.pumpAndSettle();

      expect(visibleSuggestions(), ['pikachu', 'pidgey']);
    });

    testWidgets('renders inline error text when errorText is provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: PokeTextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: reportedInputs.add,
              errorText: 'Bad request. Please try again.',
            ),
          ),
        ),
      );

      expect(find.text('Bad request. Please try again.'), findsOneWidget);
    });

    testWidgets('triggers onSubmitted callback on keyboard submission', (
      tester,
    ) async {
      String? submittedValue;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: PokeTextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: reportedInputs.add,
              onSubmitted: (val) => submittedValue = val,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'pikachu');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      expect(submittedValue, 'pikachu');
    });
  });

  group('HomePage', () {
    Future<void> pumpHomePage(
      WidgetTester tester, {
      Size? physicalSize,
      double? textScaleFactor,
    }) async {
      if (physicalSize != null) {
        tester.view.physicalSize = physicalSize;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });
      }

      await mockNetworkImagesFor(() async {
        final router = createAppRouter(initialLocation: '/');
        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) {
              if (textScaleFactor != null) {
                return MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: TextScaler.linear(textScaleFactor)),
                  child: child!,
                );
              }
              return child!;
            },
          ),
        );
        await tester.pumpAndSettle();
      });
    }

    testWidgets('search button is disabled when input is empty', (
      tester,
    ) async {
      await pumpHomePage(tester);

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('search button is enabled when input has non-whitespace text', (
      tester,
    ) async {
      await pumpHomePage(tester);

      await tester.enterText(find.byType(TextField), 'pikachu');
      await tester.pumpAndSettle();

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNotNull);
    });

    testWidgets('keyboard search action submits and navigates to detail', (
      tester,
    ) async {
      await mockNetworkImagesFor(() async {
        await pumpHomePage(tester);

        await tester.enterText(find.byType(TextField), 'pikachu');
        await tester.testTextInput.receiveAction(TextInputAction.search);
        await tester.pumpAndSettle();

        expect(find.byType(Detail), findsOneWidget);
        final detail = tester.widget<Detail>(find.byType(Detail));
        expect(detail.pokemonName, 'pikachu');
      });
    });

    testWidgets('tapping search button submits and navigates to detail', (
      tester,
    ) async {
      await mockNetworkImagesFor(() async {
        await pumpHomePage(tester);

        await tester.enterText(find.byType(TextField), 'bulbasaur');
        await tester.pumpAndSettle();

        await tester.tap(find.text('Search'), warnIfMissed: false);
        await tester.pumpAndSettle();

        expect(find.byType(Detail), findsOneWidget);
        final detail = tester.widget<Detail>(find.byType(Detail));
        expect(detail.pokemonName, 'bulbasaur');
      });
    });

    testWidgets(
      'shows autocomplete suggestions and navigates to detail on selection',
      (tester) async {
        await mockNetworkImagesFor(() async {
          await pumpHomePage(tester);

          await tester.enterText(find.byType(TextField), 'pi');
          await tester.pumpAndSettle();

          expect(find.text('pikachu'), findsOneWidget);
          expect(
            tester.getSize(find.widgetWithText(InkWell, 'pikachu')).height,
            greaterThanOrEqualTo(48.0),
          );

          await tester.tap(find.text('pikachu'), warnIfMissed: false);
          await tester.pumpAndSettle();

          expect(find.byType(Detail), findsOneWidget);
          final detail = tester.widget<Detail>(find.byType(Detail));
          expect(detail.pokemonName, 'pikachu');
        });
      },
    );

    testWidgets(
      'hardware keyboard navigation and enter submits selected suggestion without duplicate',
      (tester) async {
        await mockNetworkImagesFor(() async {
          await pumpHomePage(tester);

          await tester.enterText(find.byType(TextField), 'pi');
          await tester.pumpAndSettle();

          expect(find.text('pikachu'), findsOneWidget);

          // Navigate down to highlight the first suggestion
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
          await tester.pumpAndSettle();

          // Submit the field via search action
          await tester.testTextInput.receiveAction(TextInputAction.search);
          await tester.pumpAndSettle();

          expect(find.byType(Detail), findsOneWidget);
          final detail = tester.widget<Detail>(find.byType(Detail));
          expect(detail.pokemonName, 'pikachu');
        });
      },
    );

    testWidgets(
      'returning from detail navigation does not force soft keyboard input',
      (tester) async {
        await mockNetworkImagesFor(() async {
          await pumpHomePage(tester);

          await tester.enterText(find.byType(TextField), 'pikachu');
          await tester.testTextInput.receiveAction(TextInputAction.search);
          await tester.pumpAndSettle();

          expect(find.byType(Detail), findsOneWidget);

          // Navigate back to HomePage
          final backButton = find.byType(BackButton);
          expect(backButton, findsOneWidget);
          await tester.tap(backButton);
          await tester.pumpAndSettle();

          expect(find.byType(HomePage), findsOneWidget);
          final editableText = tester.widget<EditableText>(
            find.byType(EditableText),
          );
          expect(editableText.focusNode.hasFocus, isFalse);
        });
      },
    );

    testWidgets('renders inline error feedback on invalid input', (
      tester,
    ) async {
      await pumpHomePage(tester);

      await tester.enterText(find.byType(TextField), '???');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Search'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(PokeTextField),
          matching: find.text('Bad request. Please try again.'),
        ),
        findsOneWidget,
      );
      expect(find.byType(SnackBar), findsNothing);
    });

    final viewports = <String, Size>{
      'compact phone (320x568)': const Size(320, 568),
      'standard phone (390x844)': const Size(390, 844),
      'landscape phone (844x390)': const Size(844, 390),
      'tablet (768x1024)': const Size(768, 1024),
    };

    for (final entry in viewports.entries) {
      testWidgets('renders without overflow on ${entry.key}', (tester) async {
        await pumpHomePage(tester, physicalSize: entry.value);

        expect(tester.takeException(), isNull);
        expect(find.byType(PokeTextField), findsOneWidget);
        expect(find.byType(ElevatedButton), findsOneWidget);
        expect(find.byType(PokeBallWidget), findsOneWidget);
      });
    }

    testWidgets('renders without overflow at 2.0 text scale factor', (
      tester,
    ) async {
      await pumpHomePage(
        tester,
        physicalSize: const Size(390, 844),
        textScaleFactor: 2.0,
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(PokeTextField), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('decorative PokeBall is excluded from semantics', (
      tester,
    ) async {
      await pumpHomePage(tester);

      expect(
        find.descendant(
          of: find.byType(ExcludeSemantics),
          matching: find.byType(PokeBallWidget),
        ),
        findsOneWidget,
      );
    });

    testWidgets('app bar menu button has localized settings tooltip', (
      tester,
    ) async {
      await pumpHomePage(tester);

      final iconButton = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.menu),
      );
      expect(iconButton.tooltip, 'Settings');
    });

    testWidgets('search button meets minimum 48x48 dp touch target', (
      tester,
    ) async {
      await pumpHomePage(tester);

      final size = tester.getSize(find.byType(ElevatedButton));
      expect(size.height, greaterThanOrEqualTo(48.0));
      expect(size.width, greaterThanOrEqualTo(48.0));
    });
  });
}
