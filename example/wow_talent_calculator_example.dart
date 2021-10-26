import 'package:wow_talent_calculator/src/utils/constants.dart';
import 'package:wow_talent_calculator/wow_talent_calculator.dart';

void main() {
  var tc = WowTalentCalculator(expansionId: Expansions.vanilla.index, charClassId: CharClasses.druid.index);

  tc.investTalentPoint(0, 1);
  tc.investTalentPoint(0, 1);
  tc.investTalentPoint(0, 2);

  tc.printSpecState(0);

  tc.resetSpec(0);

  tc.printSpecState(0);

  var position = tc.getTalentTreePositionForIndex(0, 11);

  print(position.toString());
}
