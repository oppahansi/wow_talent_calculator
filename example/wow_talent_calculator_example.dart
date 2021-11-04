import 'package:wow_talent_calculator/wow_talent_calculator.dart';

void main() {
  var wtc = WowTalentCalculator(expansionId: 0, charClassId: 0);

  for (int i = 0; i < 4; i++) {
    wtc.investPointAt(0, 0);
  }

  wtc.investPointAt(0, 1);
  wtc.investPointAt(0, 2);

  for (int i = 0; i < 3; i++) {
    wtc.investPointAt(0, 4);
  }

  wtc.investPointAt(0, 0);
  wtc.investPointAt(0, 8);

  wtc.printSpec(0);
  wtc.printAllSpecs();
}
