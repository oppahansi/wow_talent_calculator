import 'package:test/test.dart';
import 'package:wow_talent_calculator/src/wow_talent_calculator.dart';

void main() {
  var wtc = WowTalentCalculator();

  group('Investing points', () {
    setUp(() {
      for (int i = 0; i < 5; i++) {
        wtc.investPointAt(0, 0);
      }
    });

    test('in an available talent, should add one point to the talent', () {
      wtc.investPointAt(0, 1);
      expect(wtc.getInvestedPointsAt(0, 1), 1);
    });

    test('in an unvailable talent, should not add a point to the talent', () {
      wtc.investPointAt(0, 8);
      expect(wtc.getInvestedPointsAt(0, 8), 0);
    });

    test('in a maxed out talent, should not add a point to the talent', () {
      int maxedOutTalentPoints = wtc.getInvestedPointsAt(0, 0);
      wtc.investPointAt(0, 0);
      expect(wtc.getInvestedPointsAt(0, 0), maxedOutTalentPoints);
    });

    test('in a not existing talent, should do nothing', () {
      wtc.investPointAt(0, 3);
      expect(wtc.getInvestedPointsAt(0, 3), -1);
    });
  });

  group('Removing points', () {
    setUp(() {
      wtc = WowTalentCalculator();

      for (int i = 0; i < 4; i++) {
        wtc.investPointAt(0, 0);
      }

      wtc.investPointAt(0, 1);
      wtc.investPointAt(0, 2);

      for (int i = 0; i < 3; i++) {
        wtc.investPointAt(0, 4);
      }
    });

    test('from an available talent, should remove one point from the talent', () {
      int talentPoints = wtc.getInvestedPointsAt(0, 0);
      wtc.removePointAt(0, 0);
      expect(wtc.getInvestedPointsAt(0, 0), talentPoints - 1);
    });

    test('should not be possible if it would break dependency to next tier', () {
      wtc.removePointAt(0, 0);

      int talentPoints = wtc.getInvestedPointsAt(0, 0);
      wtc.removePointAt(0, 0);
      expect(wtc.getInvestedPointsAt(0, 0), talentPoints);
    });

    test('from an unvailable talent, should do nothing', () {
      int talentPoints = wtc.getInvestedPointsAt(0, 8);
      wtc.removePointAt(0, 8);
      expect(wtc.getInvestedPointsAt(0, 8), talentPoints);
    });

    test('from a not existing talent, should do nothing', () {
      int talentPoints = wtc.getInvestedPointsAt(0, 3);
      wtc.removePointAt(0, 3);
      expect(wtc.getInvestedPointsAt(0, 3), talentPoints);
    });

    test('should not be possible if it would break the highest tier dependency ', () {
      wtc.investPointAt(0, 0);
      wtc.investPointAt(0, 8);

      int talentPoints = wtc.getInvestedPointsAt(0, 0);

      wtc.removePointAt(0, 0);
      expect(wtc.getInvestedPointsAt(0, 0), talentPoints);
    });
  });

  group('Spent points', () {
    setUp(() {
      wtc = WowTalentCalculator();

      for (int i = 0; i < 5; i++) {
        wtc.investPointAt(0, 0);
      }
    });

    test('should increase when point is invested in an available talent', () {
      int spentPoints = wtc.getSpentPoints(0);
      wtc.investPointAt(0, 1);
      expect(wtc.getSpentPoints(0), spentPoints + 1);
    });

    test('should not change when investing a point in an unvailable talent', () {
      int spentPoints = wtc.getSpentPoints(0);
      wtc.investPointAt(0, 8);
      expect(wtc.getSpentPoints(0), spentPoints);
    });

    test('should not change when investing a point in a maxed out talent', () {
      int spentPoints = wtc.getSpentPoints(0);
      wtc.investPointAt(0, 0);
      expect(wtc.getSpentPoints(0), spentPoints);
    });

    test('should not change when investing a point in a not existing talent', () {
      int spentPoints = wtc.getSpentPoints(0);
      wtc.investPointAt(0, 3);
      expect(wtc.getSpentPoints(0), spentPoints);
    });
  });

  group('Availability', () {
    setUp(() {
      wtc = WowTalentCalculator();

      for (int i = 0; i < 5; i++) {
        wtc.investPointAt(0, 0);
      }

      for (int i = 0; i < 5; i++) {
        wtc.investPointAt(0, 5);
      }
    });

    test('should always be given in Tier 0, unless there is a dependency in the same row', () {
      wtc.resetSpec(0);
      expect(wtc.isTalentAvailableAt(0, 0), true);
      expect(wtc.isTalentAvailableAt(0, 2), false);
    });

    test('should be given when all requirements are met', () {
      for (int i = 0; i < 3; i++) {
        wtc.investPointAt(0, 4);
      }

      for (int i = 0; i < 2; i++) {
        wtc.investPointAt(0, 8);
      }

      expect(wtc.isTalentAvailableAt(0, 13), true);
    });

    test('should not be given when not all requirements are met', () {
      expect(wtc.isTalentAvailableAt(0, 13), false);
    });
  });

  group('Build sequence', () {
    setUp(() {
      wtc = WowTalentCalculator(expansionId: 0, charClassId: 8);

      for (int i = 0; i < 2; i++) {
        wtc.investPointAt(0, 0);
      }

      for (int i = 0; i < 3; i++) {
        wtc.investPointAt(0, 2);
      }

      wtc.investPointAt(0, 5);

      for (int i = 0; i < 2; i++) {
        wtc.investPointAt(1, 2);
      }

      for (int i = 0; i < 2; i++) {
        wtc.investPointAt(2, 1);
      }

      // wtc.printBuildSequence();

      // wtc.removePointAt(0, 5);

      // wtc.printBuildSequence();

      // wtc.investPointAt(0, 5);

      // wtc.printBuildSequence();
    });

    test('should contain 10 elements after setup.', () {
      expect(wtc.getBuildSequence.length == 10, true);
    });

    test('should contain 9 elements after removing one talent point.', () {
      wtc.removePointAt(0, 5);
      expect(wtc.getBuildSequence.length == 9, true);
    });

    test('should update all sequence points in the list when one sequence point is removed from the list.', () {
      wtc.removePointAt(0, 5);

      int sequencePointBeforeRemoving = wtc.getBuildSequence[6].sequencePoint;
      wtc.removePointAt(0, 5);
      int sequencePointAfterRemoving = wtc.getBuildSequence[5].sequencePoint;

      expect(sequencePointBeforeRemoving - 1 == sequencePointAfterRemoving, true);
    });
  });
}
