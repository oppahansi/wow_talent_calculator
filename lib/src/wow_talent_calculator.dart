import 'models/talent_tree_position.dart';
import 'utils/talent_calculator_constants.dart';

class WowTalentCalculator {
  int _expansionId = 0;
  int _charClassId = 0;
  int _specId = 0;

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

  void investPointAt(int index) {
    if (!canInvestPointAt(index)) {
      return;
    }

    _treeState[_specId][index]++;
    _spentPoints++;
  }

  void removePointAt(int index) {
    if (!canRemovePointAt(index)) {
      return;
    }

    _treeState[_specId][index]--;
    _spentPoints--;
  }

  bool canInvestPointAt(int index) {
    if (areAllPointsSpent()) {
      return false;
    }

    if (!_isInputValidAt(index)) {
      return false;
    }

    if (!isTalentAvailableAt(index)) {
      return false;
    }

    if (isTalentMaxedOutAt(index)) {
      return false;
    }

    return true;
  }

  bool canRemovePointAt(int index) {
    if (!_isInputValidAt(index)) {
      return false;
    }

    if (!isTalentAvailableAt(index)) {
      return false;
    }

    if (!isSafeToRemovePointAt(index)) {
      return false;
    }

    return true;
  }

  bool isTalentAvailableAt(int index) {
    if (_spentPoints < (index ~/ 4) * 5) {
      return false;
    }

    int dependencyTreeIndex = _talentDependencies[_specId][index];
    if (dependencyTreeIndex > 0) {
      int dependencyState = _treeState[_specId][dependencyTreeIndex];
      int dependencyMaxState = _talentMaxPoints[_specId][dependencyTreeIndex];

      if (dependencyState != dependencyMaxState) {
        return false;
      }
    }

    return true;
  }

  bool isTalentMaxedOutAt(int index) {
    if (_treeState[_specId][index] == _talentMaxPoints[_specId][index]) {
      return true;
    }

    return false;
  }

  bool isPositionEmptyAt(int specId, int index) => _talentTreeLayouts[specId][index] == 0;

  bool isSafeToRemovePointAt(int index) {
    /// Check if dependent talent has points
    if (_talentDependencies[_specId].contains(index)) {
      int dependentTalent = _talentDependencies[_specId].indexOf(index);

      if (_treeState[_specId][dependentTalent] != 0) {
        return false;
      }
    }

    /// Check highest tier has only 1 point left
    int currentRow = index ~/ 4;
    if (currentRow != TalentCalculatorConstants.maxTalentTreeRows[_expansionId] - 1 && _spentPoints % 5 == 1) {
      return false;
    }

    /// Check if removing point would break dependency for the next tier
    if (getRowSumFor(currentRow) - 1 < currentRow * 5 + 5) {
      return false;
    }

    int highestRow = _spentPoints ~/ 5;
    if (_hasRowInvestedPoints(highestRow)) {
      return false;
    }

    return true;
  }

  bool areAllPointsSpent() {
    return _spentPoints == _maxTalentPoints;
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

  void printSpecState([int specId = -1]) {
    print(_buildPrintableSpecState(specId < 0 ? _specId : specId));
  }

  // * ----------------- GETTER & SETTER -----------------

  int get getSpecId => _specId;

  void setSpecId(int specId) => _specId = specId;

  int get getSpentPoints => _spentPoints;

  List<List<int>> get getTreeState => _treeState;

  void setTreeState(List<List<int>> treeState) {
    _treeState = treeState;
  }

  int getInvestedPointsAt(int index) {
    if (!_isIndexValid(index)) {
      return -1;
    }

    return _treeState[_specId][index];
  }

  int getRowSumFor(int row) {
    int rowSum = 0;

    for (int i = 0; i < 4; i++) {
      int state = _treeState[_specId][row * 4 + i];
      if (state >= 0) {
        rowSum += state;
      }
    }

    return rowSum;
  }

  Position getPositionFor(int index) => Position(
        row: index ~/ 4,
        column: index % 4,
      );

  // * ----------------- PRIVATE METHODS -----------------

  void _createTreeState(int expansionId) {
    for (List<int> spec in TalentCalculatorConstants.initialTreeState[expansionId]) {
      List<int> specState = [];
      for (int index in spec) {
        specState.add(index);
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

  bool _isInputValidAt(int index) {
    if (!_isIndexValid(index)) {
      return false;
    }

    if (isPositionEmptyAt(_specId, index)) {
      return false;
    }

    return true;
  }

  bool _isIndexValid(int index) => index >= 0 && index < _talentTreeLayouts[0].length;

  bool _hasRowInvestedPoints(int highestRow) {
    if (highestRow >= TalentCalculatorConstants.maxTalentTreeRows[_specId]) {
      return false;
    }

    for (int i = 0; i < 4; i++) {
      if (_treeState[_specId][highestRow * 4 + i] > 0) {
        return true;
      }
    }

    return false;
  }
}
