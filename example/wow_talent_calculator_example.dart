import 'package:wow_talent_calculator/wow_talent_calculator.dart';

void main() {
  var wtc = WowTalentCalculator(expansionId: 0, charClassId: 0);

  for (int i = 0; i < 5; i++) {
    wtc.investPointAt(0, 0);
  }

  wtc.investPointAt(0, 1);

  wtc.resetAll();

  var availabilities = wtc.getAvailabilityStates;

  wtc.printSpec(0);
}
