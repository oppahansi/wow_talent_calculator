import 'exceptions/talent_calculator_exception.dart';
import 'models/talent_tree_position.dart';
import 'utils/constants.dart';

class WoWTalentCalculator {
  final int expansionId;
  final int charClassId;

  int _spentPoints = 0;
  int _maxTalentPoints = 0;

  List<List<int>> _treeState = List.empty(growable: true);
  List<List<int>> _talentTreeLayouts = List.empty(growable: true);
  List<List<int>> _talentMaxPoints = List.empty(growable: true);
  List<List<int>> _talentDependencies = List.empty(growable: true);

  WoWTalentCalculator({required this.expansionId, required this.charClassId}) {
    if (expansionId < 0 ||
        expansionId >= Constants.expansionAndSpecIds.length) {
      throw TalentCalculatorException(
          "Invalid Expansion ID\nExpansion ID must be >= 0 & < ${Constants.expansionAndSpecIds.length}");
    }
    if (charClassId < 0 ||
        charClassId >= Constants.charClassesAmounts[expansionId]) {
      throw TalentCalculatorException(
          "Invalid Character Class ID\nCharacter Class ID must be >= 0 & < ${Constants.charClassesAmounts[expansionId]}");
    }

    _maxTalentPoints = Constants.maxTalentPoints[expansionId];
    _treeState =
        List.from(Constants.initialTreeState[expansionId][charClassId]);
    _talentTreeLayouts =
        List.from(Constants.talentLayouts[expansionId][charClassId]);
    _talentMaxPoints =
        List.from(Constants.talentMaxPoints[expansionId][charClassId]);
    _talentDependencies =
        List.from(Constants.talentDependencies[expansionId][charClassId]);
  }

  void investTalentPoint(int specId, int talentTreePosition) {
    if (!canInvestPoint(specId, talentTreePosition)) {
      return;
    }

    _treeState[specId][talentTreePosition]++;
    _spentPoints++;
  }

  void removeTalentPoint(int specId, int talentTreePosition) {
    if (!canRemoveTalentPoint(specId, talentTreePosition)) {
      return;
    }

    _treeState[specId][talentTreePosition]--;
    _spentPoints--;
  }

  void resetSpec(int specId) {
    _treeState[specId].asMap().forEach((index, element) {
      _spentPoints -= element;
      _treeState[specId][index] = 0;
    });
  }

  void resetAll() {
    for (int specId in Constants.expansionAndSpecIds) {
      resetSpec(specId);
    }
  }

  bool canInvestPoint(int specId, int talentTreePosition) {
    if (!isInputValid(specId, talentTreePosition)) {
      return false;
    }

    if (!isTalentAvailable(specId, talentTreePosition)) {
      return false;
    }

    if (!isTalentMaxedOut(specId, talentTreePosition)) {
      return false;
    }

    return true;
  }

  bool canRemoveTalentPoint(int specId, int talentTreePosition) {
    if (!isInputValid(specId, talentTreePosition)) {
      return false;
    }

    if (!isTalentAvailable(specId, talentTreePosition)) {
      return false;
    }

    if (!isSafeToRemoveTalentPoint(specId, talentTreePosition)) {
      return false;
    }

    return true;
  }

  bool isInputValid(int specId, int talentTreePosition) {
    if (!isSpecIdValid(specId)) {
      return false;
    }

    if (!isTalentTreePositionValid(talentTreePosition)) {
      return false;
    }

    if (!isTalentPosition(specId, talentTreePosition)) {
      return false;
    }

    return true;
  }

  bool isTalentAvailable(int specId, int talentTreePosition) {
    if (_spentPoints < (talentTreePosition ~/ 4) * 5) {
      return false;
    }

    int dependencyTreePosition =
        _talentDependencies[specId][talentTreePosition];

    if (dependencyTreePosition > 0) {
      int dependencyState = _treeState[specId][dependencyTreePosition];
      int dependencyMaxState = _talentMaxPoints[specId][dependencyTreePosition];

      if (dependencyState != dependencyMaxState) {
        return false;
      }
    }

    return true;
  }

  bool isSpecIdValid(int specId) =>
      specId >= 0 && specId < Constants.expansionAndSpecIds.length;

  bool isTalentTreePositionValid(int talentTreePosition) =>
      talentTreePosition >= 0 &&
      talentTreePosition < _talentTreeLayouts[0].length;

  bool isTalentPosition(int specId, int talentTreePosition) =>
      _talentTreeLayouts[specId][talentTreePosition] == 1;

  bool isTalentMaxedOut(int specId, int talentTreePosition) {
    if (_treeState[specId][talentTreePosition] !=
        _talentMaxPoints[specId][talentTreePosition]) {
      return false;
    }

    return true;
  }

  bool isSafeToRemoveTalentPoint(int specId, int talentTreePosition) {
    // TODO

    return true;
  }

  TalentTreePosition getTalentTreePosition(int talentTreePosition) =>
      TalentTreePosition(
        row: talentTreePosition % 4,
        column: talentTreePosition ~/ 4,
      );

  int get getSpentPoints => _spentPoints;
}
