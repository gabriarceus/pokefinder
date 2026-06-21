import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokefinder/l10n/app_localizations.dart';
import 'package:pokefinder/src/1_presentation/widgets/home/poke_text_field.dart';

void main() {
  group('HomePage', () {
    testWidgets('renders a TextField and accepts input', (tester) async {
      final controller = TextEditingController();
      final focusNode = FocusNode();
      String inputValue = '';

      // Costruisci il widget da testare
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: PokeTextField(
              controller: controller,
              focusNode: focusNode,
              allNames: const [],
              onChanged: (value) {
                inputValue = value;
              },
            ),
          ),
        ),
      );

      // L'operazione da testare: inserire un testo nel TextField
      await tester.enterText(find.byType(TextField), 'Pikachu');

      // Verifica che il testo sia stato inserito correttamente
      expect(controller.text, 'Pikachu');
      expect(inputValue, 'Pikachu');
    });
  });
}
