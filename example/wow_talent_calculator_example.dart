import 'package:wow_talent_calculator/wow_talent_calculator.dart';

void main() {
  var wtc = WowTalentCalculator();

  for (int i = 0; i < 4; i++) {
    wtc.investPointAt(0);
  }

  wtc.investPointAt(1);
  wtc.investPointAt(2);

  for (int i = 0; i < 3; i++) {
    wtc.investPointAt(4);
  }

  wtc.printSpecState();
}
