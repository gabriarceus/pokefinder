import 'package:flutter/material.dart';

class DetailBackgroundColor {
  const DetailBackgroundColor({
    required this.type,
  });

  final String type;

  Color? colorFromType() {
    switch (type) {
      case '1': // normal
        return Colors.grey[300];
      case '2': // fighting
        return Colors.orange[600];
      case '3': // flying
        return Colors.cyan[200];
      case '4': // poison
        return Colors.deepPurpleAccent[100];
      case '5': // ground
        return Colors.orange[300];
      case '6': // rock
        return Colors.brown[300];
      case '7': // bug
        return Colors.lime[400];
      case '8': // ghost
        return Colors.indigo[300];
      case '9': // steel
        return Colors.blueGrey[200];
      case '10': // fire
        return Colors.red[500];
      case '11': // water
        return Colors.blue[300];
      case '12': // grass
        return Colors.green[400];
      case '13': // electric
        return Colors.yellow[600];
      case '14': // psychic
        return Colors.pink[300];
      case '15': // ice
        return Colors.cyanAccent[100];
      case '16': // dragon
        return Colors.deepPurple[900];
      case '17': // dark
        return Colors.black54;
      case '18': // fairy
        return Colors.pink[100];
      case '19': // stellar
        return Colors.deepPurple[300];
      default: // unknown
        return Colors.grey[300];
    }
  }
}
