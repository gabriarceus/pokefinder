import 'package:flutter/material.dart';

/// Returns the display color associated with [game].
///
/// The default branch returns [Colors.grey] as an explicit fallback for
/// version strings not covered by the known set — the input comes from the
/// API and is open-ended, so exhaustiveness cannot be enforced at compile time.
Color gameVersionColor(String game) {
  switch (game.toLowerCase()) {
    case 'red':
    case 'firered':
      return Colors.red;
    case 'blue':
    case 'leafgreen':
      return Colors.blue;
    case 'yellow':
      return Colors.amber.shade700;
    case 'gold':
    case 'heartgold':
      return Colors.orange.shade400;
    case 'silver':
    case 'soulsilver':
      return Colors.blueGrey;
    case 'crystal':
      return Colors.cyan;
    case 'ruby':
    case 'omega-ruby':
      return Colors.red.shade900;
    case 'sapphire':
    case 'alpha-sapphire':
      return Colors.blue.shade900;
    case 'emerald':
      return Colors.green.shade800;
    case 'diamond':
      return Colors.lightBlue;
    case 'pearl':
      return Colors.pink.shade300;
    case 'platinum':
      return Colors.purple.shade300;
    case 'black':
    case 'black-2':
      return Colors.black;
    case 'white':
    case 'white-2':
      return Colors.grey.shade400;
    case 'x':
      return Colors.blue.shade800;
    case 'y':
      return Colors.red.shade800;
    case 'sun':
    case 'ultra-sun':
      return Colors.orange;
    case 'moon':
    case 'ultra-moon':
      return Colors.indigo;
    case 'sword':
      return Colors.cyan.shade800;
    case 'shield':
      return Colors.red.shade700;
    case 'scarlet':
      return Colors.redAccent;
    case 'violet':
      return Colors.deepPurple;
    default:
      return Colors.grey;
  }
}
