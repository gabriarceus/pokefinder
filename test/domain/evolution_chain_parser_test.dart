import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokefinder/src/4_repository/models/raw_evolution_chain/raw_evolution_chain.dart';

void main() {
  group('Evolution Chain Parsing', () {
    test(
      'parses linear evolution chain (Charmander -> Charmeleon -> Charizard)',
      () {
        final json =
            jsonDecode('''
      {
        "id": 2,
        "chain": {
          "is_baby": false,
          "species": {
            "name": "charmander",
            "url": "https://pokeapi.co/api/v2/pokemon-species/4/"
          },
          "evolution_details": [],
          "evolves_to": [
            {
              "is_baby": false,
              "species": {
                "name": "charmeleon",
                "url": "https://pokeapi.co/api/v2/pokemon-species/5/"
              },
              "evolution_details": [
                {
                  "trigger": { "name": "level-up", "url": "https://pokeapi.co/api/v2/evolution-trigger/1/" },
                  "min_level": 16
                }
              ],
              "evolves_to": [
                {
                  "is_baby": false,
                  "species": {
                    "name": "charizard",
                    "url": "https://pokeapi.co/api/v2/pokemon-species/6/"
                  },
                  "evolution_details": [
                    {
                      "trigger": { "name": "level-up", "url": "https://pokeapi.co/api/v2/evolution-trigger/1/" },
                      "min_level": 36
                    }
                  ],
                  "evolves_to": []
                }
              ]
            }
          ]
        }
      }
      ''')
                as Map<String, dynamic>;

        final raw = RawEvolutionChain.fromJson(json);
        expect(raw.id, 2);
        expect(raw.chain.species.name, 'charmander');
        expect(raw.chain.evolvesTo.length, 1);

        final charmeleon = raw.chain.evolvesTo.first;
        expect(charmeleon.species.name, 'charmeleon');
        expect(charmeleon.evolutionDetails.first.trigger?.name, 'level-up');
        expect(charmeleon.evolutionDetails.first.minLevel, 16);

        final charizard = charmeleon.evolvesTo.first;
        expect(charizard.species.name, 'charizard');
        expect(charizard.evolutionDetails.first.minLevel, 36);
        expect(charizard.evolvesTo, isEmpty);
      },
    );

    test(
      'parses branched evolution chain (Eevee with 8 evolution branches)',
      () {
        final json =
            jsonDecode('''
      {
        "id": 67,
        "chain": {
          "is_baby": false,
          "species": {
            "name": "eevee",
            "url": "https://pokeapi.co/api/v2/pokemon-species/133/"
          },
          "evolution_details": [],
          "evolves_to": [
            {
              "species": { "name": "vaporeon", "url": "https://pokeapi.co/api/v2/pokemon-species/134/" },
              "evolution_details": [{ "trigger": { "name": "use-item", "url": "" }, "item": { "name": "water-stone", "url": "" } }],
              "evolves_to": []
            },
            {
              "species": { "name": "jolteon", "url": "https://pokeapi.co/api/v2/pokemon-species/135/" },
              "evolution_details": [{ "trigger": { "name": "use-item", "url": "" }, "item": { "name": "thunder-stone", "url": "" } }],
              "evolves_to": []
            },
            {
              "species": { "name": "flareon", "url": "https://pokeapi.co/api/v2/pokemon-species/136/" },
              "evolution_details": [{ "trigger": { "name": "use-item", "url": "" }, "item": { "name": "fire-stone", "url": "" } }],
              "evolves_to": []
            },
            {
              "species": { "name": "espeon", "url": "https://pokeapi.co/api/v2/pokemon-species/196/" },
              "evolution_details": [{ "trigger": { "name": "level-up", "url": "" }, "min_happiness": 160, "time_of_day": "day" }],
              "evolves_to": []
            },
            {
              "species": { "name": "umbreon", "url": "https://pokeapi.co/api/v2/pokemon-species/197/" },
              "evolution_details": [{ "trigger": { "name": "level-up", "url": "" }, "min_happiness": 160, "time_of_day": "night" }],
              "evolves_to": []
            },
            {
              "species": { "name": "leafeon", "url": "https://pokeapi.co/api/v2/pokemon-species/470/" },
              "evolution_details": [{ "trigger": { "name": "level-up", "url": "" }, "location": { "name": "eterna-forest", "url": "" } }],
              "evolves_to": []
            },
            {
              "species": { "name": "glaceon", "url": "https://pokeapi.co/api/v2/pokemon-species/471/" },
              "evolution_details": [{ "trigger": { "name": "level-up", "url": "" }, "location": { "name": "sinnoh-route-217", "url": "" } }],
              "evolves_to": []
            },
            {
              "species": { "name": "sylveon", "url": "https://pokeapi.co/api/v2/pokemon-species/700/" },
              "evolution_details": [{ "trigger": { "name": "level-up", "url": "" }, "min_happiness": 160, "known_move_type": { "name": "fairy", "url": "" } }],
              "evolves_to": []
            }
          ]
        }
      }
      ''')
                as Map<String, dynamic>;

        final raw = RawEvolutionChain.fromJson(json);
        expect(raw.id, 67);
        expect(raw.chain.species.name, 'eevee');
        expect(raw.chain.evolvesTo.length, 8);

        final branchNames = raw.chain.evolvesTo
            .map((e) => e.species.name)
            .toList();
        expect(branchNames, [
          'vaporeon',
          'jolteon',
          'flareon',
          'espeon',
          'umbreon',
          'leafeon',
          'glaceon',
          'sylveon',
        ]);

        final vaporeon = raw.chain.evolvesTo[0];
        expect(vaporeon.evolutionDetails.first.trigger?.name, 'use-item');
        expect(vaporeon.evolutionDetails.first.item?.name, 'water-stone');

        final espeon = raw.chain.evolvesTo[3];
        expect(espeon.evolutionDetails.first.minHappiness, 160);
        expect(espeon.evolutionDetails.first.timeOfDay, 'day');

        final leafeon = raw.chain.evolvesTo[5];
        expect(leafeon.evolutionDetails.first.location?.name, 'eterna-forest');

        final sylveon = raw.chain.evolvesTo[7];
        expect(sylveon.evolutionDetails.first.knownMoveType?.name, 'fairy');
      },
    );

    test(
      'parses complex triggers (Trade with held item, location, stats comparison)',
      () {
        final json =
            jsonDecode('''
      {
        "id": 97,
        "chain": {
          "is_baby": false,
          "species": { "name": "onix", "url": "https://pokeapi.co/api/v2/pokemon-species/95/" },
          "evolution_details": [],
          "evolves_to": [
            {
              "species": { "name": "steelix", "url": "https://pokeapi.co/api/v2/pokemon-species/208/" },
              "evolution_details": [
                {
                  "trigger": { "name": "trade", "url": "" },
                  "held_item": { "name": "metal-coat", "url": "" }
                }
              ],
              "evolves_to": []
            }
          ]
        }
      }
      ''')
                as Map<String, dynamic>;

        final raw = RawEvolutionChain.fromJson(json);
        final steelix = raw.chain.evolvesTo.first;
        expect(steelix.evolutionDetails.first.trigger?.name, 'trade');
        expect(steelix.evolutionDetails.first.heldItem?.name, 'metal-coat');
      },
    );

    test('parses min_beauty and min_affection in evolution details', () {
      final json =
          jsonDecode('''
      {
        "id": 178,
        "chain": {
          "is_baby": false,
          "species": { "name": "feebas", "url": "https://pokeapi.co/api/v2/pokemon-species/349/" },
          "evolution_details": [],
          "evolves_to": [
            {
              "species": { "name": "milotic", "url": "https://pokeapi.co/api/v2/pokemon-species/350/" },
              "evolution_details": [
                {
                  "trigger": { "name": "level-up", "url": "" },
                  "min_beauty": 170
                },
                {
                  "trigger": { "name": "level-up", "url": "" },
                  "min_affection": 2,
                  "known_move_type": { "name": "fairy", "url": "" }
                }
              ],
              "evolves_to": []
            }
          ]
        }
      }
      ''')
              as Map<String, dynamic>;

      final raw = RawEvolutionChain.fromJson(json);
      final milotic = raw.chain.evolvesTo.first;
      expect(milotic.evolutionDetails[0].minBeauty, 170);
      expect(milotic.evolutionDetails[1].minAffection, 2);
      expect(milotic.evolutionDetails[1].knownMoveType?.name, 'fairy');
    });
  });
}
