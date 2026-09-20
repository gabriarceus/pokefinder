// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final client = HttpClient();
  final request = await client.getUrl(
    Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=1025'),
  );
  final response = await request.close();
  final body = await response.transform(utf8.decoder).join();
  client.close();

  final json = jsonDecode(body) as Map<String, dynamic>;
  final results = json['results'] as List<dynamic>;

  final nameToId = <String, int>{};
  final idToName = <int, String>{};

  const defaultSuffixes = [
    '-normal',
    '-altered',
    '-land',
    '-standard',
    '-incarnate',
    '-ordinary',
    '-aria',
    '-male',
    '-shield',
    '-average',
    '-50',
    '-baile',
    '-midday',
    '-solo',
    '-red-meteor',
    '-disguised',
    '-amped',
    '-ice',
    '-full-belly',
    '-single-strike',
    '-plant',
    '-red-striped',
    '-two-segment',
    '-zero',
    '-family-of-four',
    '-curly',
    '-green-plumage',
  ];

  for (final raw in results) {
    final name = raw['name'] as String;
    final url = raw['url'] as String;
    final trimmed = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
    final id = int.parse(trimmed.substring(trimmed.lastIndexOf('/') + 1));

    nameToId[name] = id;
    idToName[id] = name;

    for (final suffix in defaultSuffixes) {
      if (name.endsWith(suffix)) {
        final base = name.substring(0, name.length - suffix.length);
        nameToId[base] = id;
        break;
      }
    }
  }

  final buffer = StringBuffer();
  buffer.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
  buffer.writeln('// Generated from PokeAPI 1025 canonical species catalog.');
  buffer.writeln();
  buffer.writeln(
    '/// Canonical Pokédex species name slug to ID mapping (1–1025).',
  );
  buffer.writeln('const Map<String, int> kCanonicalSpeciesNameToId = {');
  for (final entry in nameToId.entries) {
    buffer.writeln("  '${entry.key}': ${entry.value},");
  }
  buffer.writeln('};');
  buffer.writeln();
  buffer.writeln(
    '/// Canonical Pokédex ID (1–1025) to official species name slug mapping.',
  );
  buffer.writeln('const Map<int, String> kCanonicalSpeciesIdToName = {');
  for (final entry in idToName.entries) {
    buffer.writeln("  ${entry.key}: '${entry.value}',");
  }
  buffer.writeln('};');

  final outputFile = File(
    'lib/src/3_domain/helpers/canonical_species_data.dart',
  );
  outputFile.writeAsStringSync(buffer.toString());
  print(
    'Successfully generated ${outputFile.path} with ${nameToId.length} names and ${idToName.length} species.',
  );
}
