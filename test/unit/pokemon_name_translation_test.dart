import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokefinder/l10n/translation_helper.dart';
import '../helpers/pump_app.dart';

void main() {
  testWidgets('translatePokemonName matches the Pokédex card names', (
    tester,
  ) async {
    late BuildContext context;
    await tester.pumpApp(
      home: Builder(
        builder: (c) {
          context = c;
          return const SizedBox.shrink();
        },
      ),
    );

    String name(String name, int id, String species) =>
        context.translatePokemonName(name: name, id: id, speciesName: species);

    expect(name('mr-mime', 122, 'mr-mime'), 'Mr. Mime');
    expect(name('ho-oh', 250, 'ho-oh'), 'Ho-Oh');
    expect(name('charizard-mega-x', 10034, 'charizard'), 'Mega Charizard X');
    expect(name('giratina-altered', 487, 'giratina'), 'Giratina');
  });
}
