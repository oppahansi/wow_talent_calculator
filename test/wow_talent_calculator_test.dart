import 'package:wow_talent_calculator/wow_talent_calculator.dart';
import 'package:test/test.dart';

void main() {
  var tc = WowTalentCalculator(expansionId: -1, charClassId: 0);

  group('A group of tests', () {
    setUp(() {});

    test('First Test', () {
      tc.printCharClassState();
      tc.printSpecState(2);
    });
  });
}
