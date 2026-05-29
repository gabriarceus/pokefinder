import 'package:flutter/material.dart';

class TypeColorScheme {
  const TypeColorScheme({
    required this.type1,
    this.type2,
  });

  final String type1;
  final String? type2;

  Color _getColorFromType(String type) {
    switch (type) {
      case '1': // normal
        return Colors.grey[300]!;
      case '2': // fighting
        return Colors.orange[600]!;
      case '3': // flying
        return Colors.cyan[200]!;
      case '4': // poison
        return Colors.deepPurpleAccent[100]!;
      case '5': // ground
        return Colors.orange[300]!;
      case '6': // rock
        return Colors.brown[300]!;
      case '7': // bug
        return Colors.lime[400]!;
      case '8': // ghost
        return Colors.indigo[300]!;
      case '9': // steel
        return Colors.blueGrey[200]!;
      case '10': // fire
        return Colors.red[500]!;
      case '11': // water
        return Colors.blue[300]!;
      case '12': // grass
        return Colors.green[400]!;
      case '13': // electric
        return Colors.yellow[600]!;
      case '14': // psychic
        return Colors.pink[300]!;
      case '15': // ice
        return Colors.cyanAccent[100]!;
      case '16': // dragon
        return Colors.deepPurple[900]!;
      case '17': // dark
        return Colors.black54;
      case '18': // fairy
        return Colors.pink[100]!;
      case '19': // stellar
        return Colors.deepPurple[300]!;
      default: // unknown
        return Colors.grey[300]!;
    }
  }

  BoxDecoration getBackgroundDecoration() {
    final color1 = _getColorFromType(type1);

    if (type2 != null && type2!.isNotEmpty) {
      final color2 = _getColorFromType(type2!);
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
