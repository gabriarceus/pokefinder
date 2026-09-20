import 'package:flutter_test/flutter_test.dart';
import 'package:pokefinder/src/3_domain/entities/learn_method.dart';

void main() {
  group('LearnMethod', () {
    test('maps recognized PokeAPI wire strings to enum variants', () {
      expect(LearnMethod.fromApi('level-up'), LearnMethod.levelUp);
      expect(LearnMethod.fromApi('machine'), LearnMethod.machine);
      expect(LearnMethod.fromApi('tutor'), LearnMethod.tutor);
      expect(LearnMethod.fromApi('egg'), LearnMethod.egg);
    });

    test('returns null for unknown wire codes', () {
      expect(LearnMethod.fromApi('unknown-method'), isNull);
      expect(LearnMethod.fromApi(''), isNull);
    });

    test('exposes matching apiValue on each variant', () {
      expect(LearnMethod.levelUp.apiValue, 'level-up');
      expect(LearnMethod.machine.apiValue, 'machine');
      expect(LearnMethod.tutor.apiValue, 'tutor');
      expect(LearnMethod.egg.apiValue, 'egg');
    });
  });
}
