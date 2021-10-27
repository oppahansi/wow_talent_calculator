import 'package:wow_talent_calculator/src/utils/talent_calculator_constants.dart';
import 'package:wow_talent_calculator/wow_talent_calculator.dart';

void main() {
  var tc = WowTalentCalculator(expansionId: Expansions.vanilla.index, charClassId: CharClasses.druid.index);
  tc.setSpecId(0);

  tc.investPointAt(0);
  tc.investPointAt(0);
  tc.investPointAt(0);
  tc.investPointAt(0);
  tc.investPointAt(0);

  tc.printSpecState();

  tc.investPointAt(4);
  tc.investPointAt(4);

  tc.printSpecState();

  tc.removePointAt(0);

  tc.printSpecState();

  tc.investPointAt(1);
  tc.investPointAt(2);

  tc.printSpecState();

  tc.removePointAt(1);

  tc.printSpecState();

  tc.investPointAt(6);

  tc.printSpecState();

  tc.investPointAt(11);
  tc.investPointAt(11);

  tc.printSpecState();

  tc.removePointAt(0);

  tc.printSpecState();

  tc.removePointAt(4);

  tc.printSpecState();

  print(tc.getInvestedPointsAt(4));
}
