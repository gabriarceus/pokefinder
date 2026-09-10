import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokefinder/l10n/app_localizations.dart';
import 'package:pokefinder/src/1_presentation/widgets/home/poke_text_field.dart';
import 'package:pokefinder/src/3_domain/failures/pokemon_failure.dart';

void main() {
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
              allNames: allNames,
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
  });
}
