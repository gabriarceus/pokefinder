import 'package:flutter_test/flutter_test.dart';
import 'package:pokefinder/src/3_domain/helpers/string_casing_extensions.dart';

void main() {
  group('capitalize', () {
    test('upper-cases only the first character', () {
      expect('fire'.capitalize(), 'Fire');
      expect('aBC'.capitalize(), 'ABC');
    });

    test('returns empty string unchanged', () {
      expect(''.capitalize(), '');
    });
  });

  group('capitalizeWords', () {
    test('capitalizes every word', () {
      expect('viridian forest'.capitalizeWords(), 'Viridian Forest');
    });

    test('collapses repeated spaces by dropping empty segments', () {
      expect('viridian   forest'.capitalizeWords(), 'Viridian Forest');
    });
  });

  group('toDisplayCase', () {
    test('replaces hyphens with spaces and capitalizes each word', () {
      expect('ultra-sun'.toDisplayCase(), 'Ultra Sun');
      expect('lets-go-pikachu'.toDisplayCase(), 'Lets Go Pikachu');
    });

    test('keeps empty segments produced by consecutive hyphens', () {
      expect('kanto--route'.toDisplayCase(), 'Kanto  Route');
    });
  });
}
