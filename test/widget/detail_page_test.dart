import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:pokefinder/widgets/detail/sprite_box_image.dart';
import 'package:pokefinder/widgets/detail/type_image.dart';
import 'package:pokefinder/widgets/detail/detail_formatter_bold.dart';

void main() {
  group('DetailPage', () {
    // Errore: non può caricare l'immagine percé deve fare una richiesta http
    testWidgets('renders an image', (WidgetTester tester) async {
      String sprite =
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png';

      await mockNetworkImagesFor(() async {
        // Costruisci il widget da testare
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SpriteBoxImage(sprite: sprite),
            ),
          ),
        );

        // L'operazione da testare: verificare che l'immagine venga caricata correttamente
        await tester.pumpAndSettle();

        // Verifica che l'immagine sia stata caricata correttamente
        expect(find.byType(Image), findsOneWidget);
      });
    });

    // Errore: non può caricare l'immagine percé deve fare una richiesta http
    group('TypeImage', () {
      testWidgets(
          'make sure second type is not displayed if there is no second type',
          (tester) async {
        String type = '';

        await mockNetworkImagesFor(() async {
          // Costruisci il widget da testare
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: TypeImage(type: type),
              ),
            ),
          );

          // L'operazione da testare: verificare che il secondo tipo non venga visualizzato se non è presente
          await tester.pumpAndSettle();

          // Verifica che l'immagine non venga visualizzata
          expect(find.byType(Image), findsNothing);

          // Verifica che il SizedBox vuoto venga visualizzato
          expect(find.byType(SizedBox), findsOneWidget);
        });
      });
    });

    testWidgets(
        'make sure second or third ability is not displayed if there is none',
        (tester) async {
      String label = 'Ability 1: ';
      String ability = '';

      // Costruisci il widget da testare
      await tester.pumpWidget(
        DetailFormatterBold(label: label, value: ability, textColor: Colors.black,),
      );

      // L'operazione da testare: verificare che il secondo o terzo tipo  non venga visualizzato se non è presente
      await tester.pumpAndSettle();

      // Verifica che non sia comparso nulla
      expect(find.byType(Row), findsNothing);
    });
  });
}
