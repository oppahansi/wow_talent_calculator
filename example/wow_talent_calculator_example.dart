import 'package:wow_talent_calculator/wow_talent_calculator.dart';

void main() {
  var wtc = WowTalentCalculator(expansionId: 0, charClassId: 8);

  // Standart DW Fury

  // Read Additional Info in the package readme for all expansion and
  // character class ids.

  // expansionId: 0 -> Vanilla / Classic
  // charClassId: 8 -> Warrior

  // specId 0
  // Arms (17)
  for (int i = 0; i < 2; i++) {
    wtc.investPointAt(0, 0);
  }

  for (int i = 0; i < 3; i++) {
    wtc.investPointAt(0, 2);
  }

  for (int i = 0; i < 5; i++) {
    wtc.investPointAt(0, 5);
  }

  wtc.investPointAt(0, 8);
  wtc.investPointAt(0, 9);

  for (int i = 0; i < 3; i++) {
    wtc.investPointAt(0, 10);
  }

  for (int i = 0; i < 2; i++) {
    wtc.investPointAt(0, 14);
  }

  // specId 1
  // Fury (34)

  for (int i = 0; i < 5; i++) {
    wtc.investPointAt(1, 2);
  }

  for (int i = 0; i < 5; i++) {
    wtc.investPointAt(1, 6);
  }

  for (int i = 0; i < 5; i++) {
    wtc.investPointAt(1, 11);
  }

  for (int i = 0; i < 5; i++) {
    wtc.investPointAt(1, 12);
  }

  for (int i = 0; i < 2; i++) {
    wtc.investPointAt(1, 13);
  }

  for (int i = 0; i < 5; i++) {
    wtc.investPointAt(1, 14);
  }

  wtc.investPointAt(1, 17);

  for (int i = 0; i < 5; i++) {
    wtc.investPointAt(1, 22);
  }

  wtc.investPointAt(1, 25);

  wtc.printAllSpecs();

  /**
   * Expected console output:
    __________________________________________
    | 2  0  3    ||    0  5    ||    0  0    |
    |       |    ||            ||    |       |
    | 0  5  |  0 ||    0  5    || 0  |  0  0 |
    |    |  |    ||            || |  |       |
    | 1  1  3    || 0  0  0  5 || 0  0  0  0 |
    |       |    ||            ||            |
    |    0  2    || 5  2  5    || 0  0  0    |
    |            ||       |    ||            |
    | 0  0  0  0 || 0  1  |  0 || 0  0  0    |
    |    |       ||    |  |    ||    |       |
    | 0  |  0    || 0  |  5    ||    |  0    |
    |    |       ||    |       ||    |       |
    |    0       ||    1       ||    0       |
    __________________________________________

   */
}
