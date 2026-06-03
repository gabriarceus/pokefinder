import 'package:flutter/material.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon_type.dart';

class TypeColorScheme {
  const TypeColorScheme({
    required this.type1,
    this.type2,
  });

  final PokemonType? type1;
  final PokemonType? type2;

  Color _getColorFromType(PokemonType? type) {
    return switch (type) {
      PokemonType.normal => Colors.grey[300]!,
      PokemonType.fighting => Colors.orange[600]!,
      PokemonType.flying => Colors.cyan[200]!,
      PokemonType.poison => Colors.deepPurpleAccent[100]!,
      PokemonType.ground => Colors.orange[300]!,
      PokemonType.rock => Colors.brown[300]!,
      PokemonType.bug => Colors.lime[400]!,
      PokemonType.ghost => Colors.indigo[300]!,
      PokemonType.steel => Colors.blueGrey[200]!,
      PokemonType.fire => Colors.red[500]!,
      PokemonType.water => Colors.blue[300]!,
      PokemonType.grass => Colors.green[400]!,
      PokemonType.electric => Colors.yellow[600]!,
      PokemonType.psychic => Colors.pink[300]!,
      PokemonType.ice => Colors.cyanAccent[100]!,
      PokemonType.dragon => Colors.deepPurple[900]!,
      PokemonType.dark => Colors.black54,
      PokemonType.fairy => Colors.pink[100]!,
      PokemonType.stellar => Colors.deepPurple[300]!,
      null => Colors.grey[300]!,
    };
  }

  BoxDecoration getBackgroundDecoration() {
    final color1 = _getColorFromType(type1);

    if (type2 != null) {
      final color2 = _getColorFromType(type2);
      return BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color1, color2],
          stops: const [0.0, 0.4],
        ),
      );
    }

    final isLight = color1.computeLuminance() > 0.5;
    final color2 = isLight ? darken(color1, 0.2) : lighten(color1, 0.2);

    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [color1, color2],
        stops: const [0.0, 0.4],
      ),
    );
  }

  Color darken(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  Color lighten(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslLight =
        hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }

  Color colorFromType() {
    return _getColorFromType(type1);
  }
}
