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
  wtc.printBuildSequence();

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

    Here:
    - No.
      - the number of the sequence point, sequence point order

    - 0:1
      - 0 is the talent index
      - 1 talent rank / invested points at that sequence point

    Build sequence:
    No. 1: 0:1
    No. 2: 0:2
    No. 3: 2:1
    No. 4: 2:2
    No. 5: 2:3
    No. 6: 5:1
    No. 7: 5:2
    No. 8: 5:3
    No. 9: 5:4
    No. 10: 5:5
    No. 11: 8:1
    No. 12: 9:1
    No. 13: 10:1
    No. 14: 10:2
    No. 15: 10:3
    No. 16: 14:1
    No. 17: 14:2
    No. 18: 2:1
    No. 19: 2:2
    No. 20: 2:3
    No. 21: 2:4
    No. 22: 2:5
    No. 23: 6:1
    No. 24: 6:2
    No. 25: 6:3
    No. 26: 6:4
    No. 27: 6:5
    No. 28: 11:1
    No. 29: 11:2
    No. 30: 11:3
    No. 31: 11:4
    No. 32: 11:5
    No. 33: 12:1
    No. 34: 12:2
    No. 35: 12:3
    No. 36: 12:4
    No. 37: 12:5
    No. 38: 13:1
    No. 39: 13:2
    No. 40: 14:1
    No. 41: 14:2
    No. 42: 14:3
    No. 43: 14:4
    No. 44: 14:5
    No. 45: 17:1
    No. 46: 22:1
    No. 47: 22:2
    No. 48: 22:3
    No. 49: 22:4
    No. 50: 22:5
    No. 51: 25:1
   */
}
