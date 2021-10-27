import 'package:wow_talent_calculator/wow_talent_calculator.dart';

void main() {
  var wtc = WowTalentCalculator(expansionId: 0, charClassId: 8);

  wtc.setSpecId(2);

  for (int i = 0; i < 4; i++) {
    wtc.investPointAt(1);
  }

  wtc.printSpec();
}
