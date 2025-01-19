import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:pokefinder/models/pokemon.dart';
import 'package:pokefinder/widgets/detail/detail_widgets.dart';

class DetailComponents extends StatelessWidget {
  const DetailComponents({
    super.key,
    required this.pokemon,
    required this.textColor,
  });

  final Pokemon pokemon;
  final Color textColor;
  final hGap = 16.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          SizedBox(width: hGap),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Text(
                    '#${pokemon.id}: ${pokemon.name[0].toUpperCase()}${pokemon.name.substring(1)}',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: textColor),
                  ),
                ),
                // Inserisco dei SizedBox vuoti quando la stringa è vuota perché tanto non verranno visualizzati
                // Le immagini di tipo sono 144x32
                const Gap(5),
                TypeImage(type: pokemon.typeImage1),
                const Gap(5),
                // Non tutti i pokemon hanno 2 tipi
                TypeImage(type: pokemon.typeImage2),
                const Gap(10),
                // Abilità 1
                DetailFormatterBold(
                  label: 'Ability 1',
                  value: pokemon.ability1,
                  textColor: textColor,
                ),
                // Abilità 2
                DetailFormatterBold(
                  label: 'Ability 2',
                  value: pokemon.ability2,
                  textColor: textColor,
                ),
                // Abilità 3
                DetailFormatterBold(
                  label: 'Ability 3',
                  value: pokemon.ability3,
                  textColor: textColor,
                ),
                DetailFormatterBold(
                  label: 'Weight',
                  value: '${pokemon.weight / 10} kg',
                  textColor: textColor,
                ), //da dg a kg
                DetailFormatterBold(
                  label: 'Height',
                  value: '${pokemon.height / 10} m',
                  textColor: textColor,
                ), //da dm a m
              ],
            ),
          ),
          // Le immagini pokemon sono 96x96
          SpriteBoxImage(sprite: pokemon.sprite),
        ],
      ),
    );
  }
}

Color itemColorExtractor(Color? backgroundColor) {
  return backgroundColor!.computeLuminance() > 0.5
      ? Colors.black
      : Colors.white;
}
