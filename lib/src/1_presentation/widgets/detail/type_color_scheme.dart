import 'package:flutter/material.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon_type.dart';

/// Opaque display colors of the Pokémon types.
abstract final class TypeColorScheme {
  /// Returns the color of [type]; a null type uses the normal-type color.
  static Color getColorFromType(PokemonType? type) {
    return switch (type) {
      PokemonType.normal || null => const Color(0xFFA8A77A),
      PokemonType.fighting => const Color(0xFFC22E28),
      PokemonType.flying => const Color(0xFFA98FF3),
      PokemonType.poison => const Color(0xFFA33EA1),
      PokemonType.ground => const Color(0xFFE2BF65),
      PokemonType.rock => const Color(0xFFB6A136),
      PokemonType.bug => const Color(0xFFA6B91A),
      PokemonType.ghost => const Color(0xFF735797),
      PokemonType.steel => const Color(0xFFB7B7CE),
      PokemonType.fire => const Color(0xFFEE8130),
      PokemonType.water => const Color(0xFF6390F0),
      PokemonType.grass => const Color(0xFF7AC74C),
      PokemonType.electric => const Color(0xFFF7D02C),
      PokemonType.psychic => const Color(0xFFF95587),
      PokemonType.ice => const Color(0xFF96D9D6),
      PokemonType.dragon => const Color(0xFF6F35FC),
      PokemonType.dark => const Color(0xFF705746),
      PokemonType.fairy => const Color(0xFFD685AD),
      PokemonType.stellar => const Color(0xFF40B5A5),
    };
  }

  /// Returns the background gradient for a Pokémon of [type1] and [type2].
  ///
  /// A single-type Pokémon fades to a lighter or darker shade of its color.
  static LinearGradient gradient(PokemonType? type1, PokemonType? type2) {
    final color1 = getColorFromType(type1);
    final Color color2;
    if (type2 != null) {
      color2 = getColorFromType(type2);
    } else {
      final hsl = HSLColor.fromColor(color1);
      final shift = color1.computeLuminance() > 0.5 ? -0.2 : 0.2;
      color2 = hsl
          .withLightness((hsl.lightness + shift).clamp(0.0, 1.0))
          .toColor();
    }
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [color1, color2],
      stops: const [0.0, 0.4],
    );
  }
}
