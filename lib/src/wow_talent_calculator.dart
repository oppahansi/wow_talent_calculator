import 'exceptions/talent_calculator_exception.dart';
import 'models/talent_tree_position.dart';
import 'utils/constants.dart';

class WoWTalentCalculator {
  final int expansionId;
  final int charClassId;

  int _spentPoints = 0;
  int _maxTalentPoints = 0;

  List<List<int>> _treeState = [];
  List<List<int>> _talentTreeLayouts = [];
  List<List<int>> _talentMaxPoints = [];
  List<List<int>> _talentDependencies = [];
  List<String> _specPrintTemplates = [];

  WoWTalentCalculator({required this.expansionId, required this.charClassId}) {
    if (expansionId < 0 || expansionId >= Constants.expansionAndSpecIds.length) {
      throw TalentCalculatorException(
          "Invalid Expansion ID!\nExpansion ID must be >= 0 & < ${Constants.expansionAndSpecIds.length}.");
    }
    if (charClassId < 0 || charClassId >= Constants.charClassesAmounts[expansionId]) {
      throw TalentCalculatorException(
          "Invalid Character Class ID!\nCharacter Class ID must be >= 0 & < ${Constants.charClassesAmounts[expansionId]}.");
    }

    _maxTalentPoints = Constants.maxTalentPoints[expansionId];

    _talentTreeLayouts = List.from(Constants.talentLayouts[expansionId][charClassId]);
    _talentMaxPoints = List.from(Constants.talentMaxPoints[expansionId][charClassId]);
    _talentDependencies = List.from(Constants.talentDependencies[expansionId][charClassId]);
    _specPrintTemplates = List.from(Constants.specPrintTemplates[expansionId][charClassId]);

    _createTreeState(expansionId);
    _initTreeState();
  }

  void investTalentPoint(int specId, int talentTreeIndex) {
    if (!canInvestPoint(specId, talentTreeIndex)) {
      return;
    }

    _treeState[specId][talentTreeIndex]++;
    _spentPoints++;
  }

  void removeTalentPoint(int specId, int talentTreeIndex) {
    if (!canRemoveTalentPoint(specId, talentTreeIndex)) {
      return;
    }

    _treeState[specId][talentTreeIndex]--;
    _spentPoints--;
  }

  void resetSpec(int specId) {
    for (int i = 0; i < _treeState[specId].length; i++) {
      if (_treeState[specId][i] < 0) {
        continue;
      }
      _spentPoints -= _treeState[specId][i];
      _treeState[specId][i] = 0;
    }
  }

  void resetAll() {
    for (int specId in Constants.expansionAndSpecIds) {
      resetSpec(specId);
    }
  }

  bool canInvestPoint(int specId, int talentTreeIndex) {
    if (!isInputValid(specId, talentTreeIndex)) {
      return false;
    }

    if (!isTalentAvailable(specId, talentTreeIndex)) {
      return false;
    }

    if (isTalentMaxedOut(specId, talentTreeIndex)) {
      return false;
    }

    return true;
  }

  bool canRemoveTalentPoint(int specId, int talentTreeIndex) {
    if (!isInputValid(specId, talentTreeIndex)) {
      return false;
    }

    if (!isTalentAvailable(specId, talentTreeIndex)) {
      return false;
    }

    if (!isSafeToRemoveTalentPoint(specId, talentTreeIndex)) {
      return false;
    }

    return true;
  }

  bool isInputValid(int specId, int talentTreeIndex) {
    if (!isSpecIdValid(specId)) {
      return false;
    }

    if (!isTalentTreeIndexValid(talentTreeIndex)) {
      return false;
    }

    if (!isTalentPosition(specId, talentTreeIndex)) {
      return false;
    }

    return true;
  }

  bool isTalentAvailable(int specId, int talentTreeIndex) {
    if (_spentPoints < (talentTreeIndex ~/ 4) * 5) {
      return false;
    }

    int dependencyTreeIndex = _talentDependencies[specId][talentTreeIndex];

    if (dependencyTreeIndex > 0) {
      int dependencyState = _treeState[specId][dependencyTreeIndex];
      int dependencyMaxState = _talentMaxPoints[specId][dependencyTreeIndex];

      if (dependencyState != dependencyMaxState) {
        return false;
      }
    }

    return true;
  }

  bool isSpecIdValid(int specId) => specId >= 0 && specId < Constants.expansionAndSpecIds.length;

  bool isTalentTreeIndexValid(int talentTreeIndex) =>
      talentTreeIndex >= 0 && talentTreeIndex < _talentTreeLayouts[0].length;

  bool isTalentPosition(int specId, int talentTreeIndex) => _talentTreeLayouts[specId][talentTreeIndex] == 1;

  bool isTalentMaxedOut(int specId, int talentTreeIndex) {
    if (_treeState[specId][talentTreeIndex] == _talentMaxPoints[specId][talentTreeIndex]) {
      return true;
    }

    return false;
  }

  bool isSafeToRemoveTalentPoint(int specId, int talentTreeIndex) {
    // TODO

    return true;
  }

  TalentTreePosition getTalentTreePositionForIndex(int specId, int talentTreeIndex) {
    if (!isTalentTreeIndexValid(talentTreeIndex)) {
      throw TalentCalculatorException(
          "Invalid Talent Tree Position!\nPosition must be >= 0 & < ${_talentTreeLayouts[0].length}.");
    }

    return TalentTreePosition(
      row: talentTreeIndex ~/ 4,
      column: talentTreeIndex % 4,
    );
  }

  void printSpecState(int specId) {
    if (specId < 0 || specId >= Constants.expansionAndSpecIds.length) {
      throw TalentCalculatorException(
          "Invalid Spec ID!\nSpec ID must be >= 0 & < ${Constants.expansionAndSpecIds.length}.");
    }
    print(_buildPrintableSpecState(specId));
  }

  void printCharClassState() {
    String specState0 = _buildPrintableSpecState(0);
    String specState1 = _buildPrintableSpecState(1);
    String specState2 = _buildPrintableSpecState(2);

    List<String> lines0 = specState0.split(RegExp('\n'));
    List<String> lines1 = specState1.split(RegExp('\n'));
    List<String> lines2 = specState2.split(RegExp('\n'));

    for (int i = 0; i < lines0.length; i++) {
      print("${lines0[i]}${lines1[i]}${lines2[i]}");
    }
  }

  int get getSpentPoints => _spentPoints;

  void _createTreeState(int expansionId) {
    for (List<int> spec in Constants.initialTreeState[expansionId]) {
      List<int> specState = [];
      for (int talentTreeIndex in spec) {
        specState.add(talentTreeIndex);
      }

      _treeState.add(specState);
    }
  }

  void _initTreeState() {
    for (int i = 0; i < _treeState.length; i++) {
      for (int j = 0; j < _treeState[i].length; j++) {
        if (_talentTreeLayouts[i][j] == 1) {
          _treeState[i][j] = 0;
        }
      }
    }
  }

  String _buildPrintableSpecState(int specId) {
    String specState = _specPrintTemplates[specId];
    for (int talentState in _treeState[specId]) {
      if (talentState < 0) {
        continue;
      }
      specState = specState.replaceFirst(RegExp('x'), talentState.toString());
    }

    return specState;
  }
}
