import 'models/talent_tree_position.dart';
import 'utils/talent_calculator_constants.dart';

class WowTalentCalculator {
  int _expansionId = 0;
  int _charClassId = 0;

  int _spentPoints = 0;
  int _maxTalentPoints = 0;

  List<List<int>> _treeState = [];

  List<List<int>> _talentTreeLayouts = [];
  List<List<int>> _talentMaxPoints = [];
  List<List<int>> _talentDependencies = [];
  List<String> _specPrintTemplates = [];

  WowTalentCalculator({int expansionId = 0, int charClassId = 0}) {
    _expansionId = expansionId;
    _charClassId = charClassId;

    _maxTalentPoints = TalentCalculatorConstants.maxTalentPoints[_expansionId];

    _talentTreeLayouts = List.from(TalentCalculatorConstants.talentLayouts[_expansionId][_charClassId]);
    _talentMaxPoints = List.from(TalentCalculatorConstants.talentMaxPoints[_expansionId][_charClassId]);
    _talentDependencies = List.from(TalentCalculatorConstants.talentDependencies[_expansionId][_charClassId]);
    _specPrintTemplates = List.from(TalentCalculatorConstants.specPrintTemplates[_expansionId][_charClassId]);

    _createTreeState(_expansionId);
    _initTreeState();
  }

  // * ----------------- PUBLIC METHODS -----------------

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

  bool canInvestPoint(int specId, int talentTreeIndex) {
    if (!_isInputValid(specId, talentTreeIndex)) {
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
    if (!_isInputValid(specId, talentTreeIndex)) {
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

  bool isTalentMaxedOut(int specId, int talentTreeIndex) {
    if (_treeState[specId][talentTreeIndex] == _talentMaxPoints[specId][talentTreeIndex]) {
      return true;
    }

    return false;
  }

  bool isTalentTreeIndexEmpty(int specId, int talentTreeIndex) => _talentTreeLayouts[specId][talentTreeIndex] == 0;

  bool isSafeToRemoveTalentPoint(int specId, int talentTreeIndex) {
    // TODO

    return true;
  }

  TalentTreePosition getTalentTreePositionForIndex(int specId, int talentTreeIndex) => TalentTreePosition(
        row: talentTreeIndex ~/ 4,
        column: talentTreeIndex % 4,
      );

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
    for (int specId in TalentCalculatorConstants.expansionAndSpecIds) {
      resetSpec(specId);
    }
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

  // * ----------------- GETTER & SETTER -----------------

  int get getSpentPoints => _spentPoints;

  List<List<int>> get getTreeState => _treeState;

  void setTreeState(List<List<int>> treeState) {
    _treeState = treeState;
  }

  void printSpecState(int specId) {
    print(_buildPrintableSpecState(specId));
  }

  // * ----------------- PRIVATE METHODS -----------------

  void _createTreeState(int expansionId) {
    for (List<int> spec in TalentCalculatorConstants.initialTreeState[expansionId]) {
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

  bool _isInputValid(int specId, int talentTreeIndex) {
    if (!_isSpecIdValid(specId)) {
      return false;
    }

    if (!_isTalentTreeIndexValid(talentTreeIndex)) {
      return false;
    }

    if (isTalentTreeIndexEmpty(specId, talentTreeIndex)) {
      return false;
    }

    return true;
  }

  bool _isSpecIdValid(int specId) => specId >= 0 && specId < TalentCalculatorConstants.expansionAndSpecIds.length;

  bool _isTalentTreeIndexValid(int talentTreeIndex) =>
      talentTreeIndex >= 0 && talentTreeIndex < _talentTreeLayouts[0].length;
}
