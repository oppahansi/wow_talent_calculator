import 'package:test/test.dart';
import 'package:wow_talent_calculator/src/wow_talent_calculator.dart';

void main() {
  var wtc = WowTalentCalculator();

  group('Investing points', () {
    setUp(() {
      for (int i = 0; i < 5; i++) {
        wtc.investPointAt(0);
      }
    });

    test('in an available talent, should add one point to the talent', () {
      wtc.investPointAt(1);
      expect(wtc.getInvestedPointsAt(1), 1);
    });

    test('in an unvailable talent, should not add a point to the talent', () {
      wtc.investPointAt(8);
      expect(wtc.getInvestedPointsAt(8), 0);
    });

    test('in a maxed out talent, should not add a point to the talent', () {
      int maxedOutTalentPoints = wtc.getInvestedPointsAt(0);
      wtc.investPointAt(0);
      expect(wtc.getInvestedPointsAt(0), maxedOutTalentPoints);
    });

    test('in a not existing talent, should do nothing', () {
      wtc.investPointAt(3);
      expect(wtc.getInvestedPointsAt(3), -1);
    });
  });

  group('Removing points', () {
    setUp(() {
      wtc = WowTalentCalculator();

      for (int i = 0; i < 4; i++) {
        wtc.investPointAt(0);
      }

      wtc.investPointAt(1);
      wtc.investPointAt(2);

      for (int i = 0; i < 3; i++) {
        wtc.investPointAt(4);
      }
    });

    test('from an available talent, should remove one point from the talent', () {
      int talentPoints = wtc.getInvestedPointsAt(0);
      wtc.removePointAt(0);
      expect(wtc.getInvestedPointsAt(0), talentPoints - 1);
    });

    test('should not be possible if it would break dependency to next tier', () {
      wtc.removePointAt(0);

      int talentPoints = wtc.getInvestedPointsAt(0);
      wtc.removePointAt(0);
      expect(wtc.getInvestedPointsAt(0), talentPoints);
    });

    test('from an unvailable talent, should do nothing', () {
      int talentPoints = wtc.getInvestedPointsAt(8);
      wtc.removePointAt(8);
      expect(wtc.getInvestedPointsAt(8), talentPoints);
    });

    test('from a not existing talent, should do nothing', () {
      int talentPoints = wtc.getInvestedPointsAt(3);
      wtc.removePointAt(3);
      expect(wtc.getInvestedPointsAt(3), talentPoints);
    });

    test('should not be possible if it would break the highest tier dependency ', () {
      wtc.investPointAt(0);
      wtc.investPointAt(8);

      int talentPoints = wtc.getInvestedPointsAt(0);

      wtc.removePointAt(0);
      expect(wtc.getInvestedPointsAt(0), talentPoints);
    });
  });

  group('Spent points', () {
    setUp(() {
      wtc = WowTalentCalculator();

      for (int i = 0; i < 5; i++) {
        wtc.investPointAt(0);
      }
    });

    test('should increase when point is invested in an available talent', () {
      int spentPoints = wtc.getSpentPoints;
      wtc.investPointAt(1);
      expect(wtc.getSpentPoints, spentPoints + 1);
    });

    test('should not change when investing a point in an unvailable talent', () {
      int spentPoints = wtc.getSpentPoints;
      wtc.investPointAt(8);
      expect(wtc.getSpentPoints, spentPoints);
    });

    test('should not change when investing a point in a maxed out talent', () {
      int spentPoints = wtc.getSpentPoints;
      wtc.investPointAt(0);
      expect(wtc.getSpentPoints, spentPoints);
    });

    test('should not change when investing a point in a not existing talent', () {
      int spentPoints = wtc.getSpentPoints;
      wtc.investPointAt(3);
      expect(wtc.getSpentPoints, spentPoints);
    });
  });

  group('Availability', () {
    setUp(() {
      wtc = WowTalentCalculator();

      for (int i = 0; i < 5; i++) {
        wtc.investPointAt(0);
      }

      for (int i = 0; i < 5; i++) {
        wtc.investPointAt(5);
      }
    });

    test('should always be given in Tier 0, unless there is a dependency in the same row', () {
      wtc.resetSpec();
      expect(wtc.isTalentAvailableAt(0), true);
      expect(wtc.isTalentAvailableAt(2), false);
    });

    test('should be given when all requirements are met', () {
      for (int i = 0; i < 3; i++) {
        wtc.investPointAt(4);
      }

      for (int i = 0; i < 2; i++) {
        wtc.investPointAt(8);
      }

      expect(wtc.isTalentAvailableAt(13), true);
    });

    test('should not be given when not all requirements are met', () {
      expect(wtc.isTalentAvailableAt(13), false);
    });
  });
}
