import 'package:flutter_test/flutter_test.dart';
import 'package:pokefinder/src/3_domain/entities/ability_detail.dart';
import 'package:pokefinder/src/3_domain/entities/pokemon_species.dart';

void main() {
  group('PokemonSpecies', () {
    const species = PokemonSpecies(
      id: 1,
      name: 'bulbasaur',
      flavorTexts: [
        PokemonSpeciesFlavorText(
          text: 'A strange seed was planted on its back at birth.',
          language: 'en',
          version: 'red',
        ),
        PokemonSpeciesFlavorText(
          text: 'Bulbasaur can be seen napping in bright sunlight.',
          language: 'en',
          version: 'ruby',
        ),
        PokemonSpeciesFlavorText(
          text:
              'È possibile vedere Bulbasaur mentre schiaccia un pisolino sotto il sole.',
          language: 'it',
          version: 'ruby',
        ),
      ],
      genera: {
        'en': 'Seed Pokémon',
        'it': 'Pokémon Seme',
        'fr': 'Pokémon Graine',
      },
      generation: 'generation-i',
      habitat: 'grassland',
    );

    test('returns localized genus with English fallback', () {
      expect(species.genusFor('it'), 'Pokémon Seme');
      expect(species.genusFor('fr'), 'Pokémon Graine');
      expect(species.genusFor('de'), 'Seed Pokémon');
      expect(species.genusFor(null), 'Seed Pokémon');
    });

    test('returns localized flavor text matching version', () {
      expect(
        species.flavorTextFor(languageCode: 'it', version: 'ruby'),
        'È possibile vedere Bulbasaur mentre schiaccia un pisolino sotto il sole.',
      );
    });

    test('falls back to English when language has no entry for version', () {
      expect(
        species.flavorTextFor(languageCode: 'it', version: 'red'),
        'A strange seed was planted on its back at birth.',
      );
    });

    test(
      'falls back to available language entry when version is all or null',
      () {
        expect(
          species.flavorTextFor(languageCode: 'it', version: 'all'),
          'È possibile vedere Bulbasaur mentre schiaccia un pisolino sotto il sole.',
        );
        expect(
          species.flavorTextFor(languageCode: 'en', version: null),
          'Bulbasaur can be seen napping in bright sunlight.',
        );
      },
    );
  });

  group('AbilityDetail', () {
    const ability = AbilityDetail(
      id: 65,
      name: 'overgrow',
      flavorTexts: {
        'en': 'Ups GRASS moves in a pinch.',
        'it': 'Potenzia le mosse di tipo Erba in difficoltà.',
      },
      effects: {
        'en':
            'When this Pokémon has 1/3 or less of its HP remaining, its Grass-type moves inflict 1.5× as much regular damage.',
        'it':
            'Quando i PS scendono sotto 1/3, la potenza delle mosse Erba aumenta del 50%.',
      },
      shortEffects: {
        'en':
            'Strengthens Grass moves to inflict 1.5× damage at 1/3 max HP or less.',
      },
    );

    test('returns localized description with fallback', () {
      // In Italian, shortEffects has no entry, so it falls back to flavorTexts['it']
      expect(
        ability.descriptionFor('it'),
        'Potenzia le mosse di tipo Erba in difficoltà.',
      );
      // In English, shortEffects['en'] is preferred
      expect(
        ability.descriptionFor('en'),
        'Strengthens Grass moves to inflict 1.5× damage at 1/3 max HP or less.',
      );
      // In German, falls back to English shortEffects
      expect(
        ability.descriptionFor('de'),
        'Strengthens Grass moves to inflict 1.5× damage at 1/3 max HP or less.',
      );
    });

    test('returns localized in-battle effect with fallback', () {
      expect(
        ability.effectFor('it'),
        'Quando i PS scendono sotto 1/3, la potenza delle mosse Erba aumenta del 50%.',
      );
      expect(
        ability.effectFor('en'),
        'When this Pokémon has 1/3 or less of its HP remaining, its Grass-type moves inflict 1.5× as much regular damage.',
      );
      expect(
        ability.effectFor('es'),
        'When this Pokémon has 1/3 or less of its HP remaining, its Grass-type moves inflict 1.5× as much regular damage.',
      );
    });
  });
}
