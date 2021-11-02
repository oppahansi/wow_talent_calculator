import 'extensions.dart';
import 'talent_calculator_constants.dart';

class WowTalentCalculator {
  int _expansionId = 0;
  int _charClassId = 0;

  List<List<int>> _treeStates = [];

  List<List<int>> _talentTreeLayouts = [];
  List<List<int>> _talentMaxPoints = [];
  List<List<int>> _talentDependencies = [];
  List<String> _specPrintTemplates = [];

  final List<int> _spentPoints = [0, 0, 0];
  final List<List<bool>> _availabilityStates = [];
  final List<List<bool>> _maxedOutStates = [];

  /// Default constructor
  ///
  /// When no parameters are provided, [expansionId] and [charclassId] are both set to 0
  /// This means expansion will be Vanilla / Classic WoW and the character class will be Druid
  WowTalentCalculator({int expansionId = 0, int charClassId = 0}) {
    _expansionId = expansionId;
    _charClassId = charClassId;

    _talentTreeLayouts = List.from(TalentCalculatorConstants.talentLayouts[_expansionId][_charClassId]);
    _talentMaxPoints = List.from(TalentCalculatorConstants.talentMaxPoints[_expansionId][_charClassId]);
    _talentDependencies = List.from(TalentCalculatorConstants.talentDependencies[_expansionId][_charClassId]);
    _specPrintTemplates = List.from(TalentCalculatorConstants.specPrintTemplates[_expansionId][_charClassId]);

    _createTreeState(_expansionId);
    _createAvailabilityStates(_expansionId);
    _createMaxedOutStates(_expansionId);

    _initTreeState();

    _updateAvailabilityStates();
    _updateMaxedOutStates();
  }

  // * ----------------- PUBLIC METHODS -----------------

  /// Invests a talent point in talent at [index]
  void investPointAt(int specId, int index) {
    if (!canInvestPointAt(specId, index)) {
      return;
    }

    _treeStates[specId][index]++;
    _spentPoints[specId]++;
    _updateAvailabilityStates();
  }

  /// Removes a talent point from talent at [index]
  void removePointAt(int specId, int index) {
    if (!canRemovePointAt(specId, index)) {
      return;
    }

    _treeStates[specId][index]--;
    _spentPoints[specId]--;
    _updateAvailabilityStates();
  }

  /// Checks whether or not it is possible to invest a talent point at [index]
  ///
  /// Checks whether or not all talent points are spent
  /// Checks whether or not input [index] is valid
  /// Checks whether or not the talent at [index] is available
  bool canInvestPointAt(int specId, int index) {
    if (areAllPointsSpent()) {
      return false;
    }

    if (!_isInputValidAt(specId, index)) {
      return false;
    }

    if (!isTalentAvailableAt(specId, index)) {
      return false;
    }

    if (isTalentMaxedOutAt(specId, index)) {
      return false;
    }

    return true;
  }

  /// Checks whether or not removing from talent at [index] is possible
  ///
  /// Checks wheter or not the inpunt [index] is valid
  /// Checks whether or not the talent at [index] is available
  /// Checks whether or not it is safe to remove a point at [index]
  bool canRemovePointAt(int specId, int index) {
    if (getInvestedPointsAt(specId, index) == 0) {
      return false;
    }

    if (!_isInputValidAt(specId, index)) {
      return false;
    }

    if (!isTalentAvailableAt(specId, index)) {
      return false;
    }

    if (!isSafeToRemovePointAt(specId, index)) {
      return false;
    }

    return true;
  }

  /// Returns true when talent at [index] is available
  ///
  /// Checks for minimum required spent points in current tree
  /// Checks for met dependencies
  bool isTalentAvailableAt(int specId, int index) {
    if (index ~/ 4 > 0 && _spentPoints[specId] < (index ~/ 4) * 5) {
      return false;
    }

    int dependencyTreeIndex = _talentDependencies[specId][index];
    if (dependencyTreeIndex > 0) {
      int dependencyState = _treeStates[specId][dependencyTreeIndex];
      int dependencyMaxState = _talentMaxPoints[specId][dependencyTreeIndex];
      int dependencyRow = dependencyTreeIndex ~/ 4;

      if (dependencyState != dependencyMaxState || _spentPoints[specId] < dependencyRow * 5) {
        return false;
      }
    }

    return true;
  }

  // Returns true when talent is maxed out
  bool isTalentMaxedOutAt(int specId, int index) {
    if (_treeStates[specId][index] == _talentMaxPoints[specId][index]) {
      return true;
    }

    return false;
  }

  /// Checks whether or not there is a talent at the specified tree index
  bool isPositionEmptyAt(int specId, int index) => _talentTreeLayouts[specId][index] == 0;

  /// Checks wheter or not it is safe to remove a talent point at [index]
  ///
  /// Checks if dependent talent has points
  /// Checks if removing point would break dependency for the next tier
  /// Checks if removing point would break highest tier
  bool isSafeToRemovePointAt(int specId, int index) {
    if (_talentDependencies[specId].contains(index)) {
      int dependentTalent = _talentDependencies[specId].indexOf(index);
      if (_treeStates[specId][dependentTalent] != 0) {
        return false;
      }
    }

    int pointsInThisTree = getSpentPoints(specId);
    int maxRows = TalentCalculatorConstants.maxTalentTreeRows[_expansionId] - 1;
    int currentRow = index ~/ 4;
    int nextRow = currentRow + 1 <= maxRows ? currentRow + 1 : maxRows;
    int highestRow = pointsInThisTree ~/ 5 >= maxRows ? maxRows - 1 : pointsInThisTree ~/ 5;
    int pointsSumUpToCurrentRow = _getPointsSumUpToRow(specId, currentRow);
    int pointsInNextRow = _getRowSumFor(specId, nextRow);
    int pointsInHighestRow = _getRowSumFor(specId, highestRow);

    if (pointsSumUpToCurrentRow - 1 < nextRow * 5 && pointsInNextRow > 0) {
      return false;
    }

    if (pointsSumUpToCurrentRow - 1 < highestRow * 5 && pointsInNextRow > 0 && pointsInHighestRow > 0) {
      return false;
    }

    if (pointsSumUpToCurrentRow - 1 < highestRow * 5 && pointsInHighestRow > 0) {
      return false;
    }

    return true;
  }

  /// Returns true when [getSpentPoints] equals [_maxTalentPoints]
  bool areAllPointsSpent() {
    return getSpentPoints() == TalentCalculatorConstants.maxTalentPoints[_expansionId];
  }

  /// Resets a spec
  ///
  /// If no [specId] is provided, the current set [specId] will be reset
  void resetSpec(int specId) {
    for (int i = 0; i < _treeStates[specId].length; i++) {
      if (_treeStates[specId][i] < 0) {
        continue;
      }

      _treeStates[specId][i] = 0;
    }

    _spentPoints[specId] = 0;
    _updateAvailabilityStates();
  }

  /// Resets all specs
  void resetAll() {
    for (int specId in TalentCalculatorConstants.expansionAndSpecIds) {
      resetSpec(specId);
    }
  }

  /// Prints all specs in console
  void printAllSpecs() {
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

  /// Prints spec
  void printSpec(int specId) {
    print(_buildPrintableSpecState(specId));
  }

  // * ----------------- GETTER & SETTER -----------------

  int getSpentPoints([int specId = -1]) {
    if (specId == -1) {
      return _spentPoints[0] + _spentPoints[1] + _spentPoints[2];
    }

    return _spentPoints[specId];
  }

  int getInvestedPointsAt(int specId, int index) {
    if (!_isIndexValid(index)) {
      return -1;
    }

    return _treeStates[specId][index];
  }

  bool getAvailabilityStateAt(int specId, int index) => _availabilityStates[specId][index];

  bool getMaxedOutStateAt(int specId, int index) => _maxedOutStates[specId][index];

  int getDependeesAmount(int specId, int index) => _talentDependencies[specId].count(index);

  int get getMaxTalentPoints => TalentCalculatorConstants.maxTalentPoints[_expansionId];

  int get getExpansionId => _expansionId;

  int get getCharClassId => _charClassId;

  List<List<int>> get getTreeStates => _treeStates;

  List<List<bool>> get getAvailabilityStates => _availabilityStates;

  List<List<bool>> get getMaxedOutStates => _maxedOutStates;

  set setTreeStates(List<List<int>> treeStates) {
    _treeStates = treeStates;

    _updateAvailabilityStates();
    _updateMaxedOutStates();
    _updateSpentPoints();
  }

  // * ----------------- PRIVATE METHODS -----------------

  void _createTreeState(int expansionId) {
    for (List<int> spec in TalentCalculatorConstants.initialTreeState[expansionId]) {
      List<int> specState = [];
      for (int index in spec) {
        specState.add(index);
      }

      _treeStates.add(specState);
    }
  }

  void _createAvailabilityStates(int expansionId) {
    for (List<bool> spec in TalentCalculatorConstants.initialAvailabilityState[expansionId]) {
      List<bool> specState = [];

      for (bool index in spec) {
        specState.add(index);
      }

      _availabilityStates.add(specState);
    }
  }

  void _initTreeState() {
    for (int i = 0; i < _treeStates.length; i++) {
      for (int j = 0; j < _treeStates[i].length; j++) {
        if (_talentTreeLayouts[i][j] == 1) {
          _treeStates[i][j] = 0;
        }
      }
    }
  }

  void _updateAvailabilityStates() {
    for (int specId = 0; specId < _availabilityStates.length; specId++) {
      for (int index = 0; index < _availabilityStates[specId].length; index++) {
        if (isPositionEmptyAt(specId, index)) {
          _availabilityStates[specId][index] = false;
        } else {
          _availabilityStates[specId][index] = isTalentAvailableAt(specId, index);
        }
      }
    }
  }

  void _createMaxedOutStates(int expansionId) {
    for (List<bool> spec in TalentCalculatorConstants.initialMaxedOutState[expansionId]) {
      List<bool> specState = [];

      for (bool index in spec) {
        specState.add(index);
      }

      _maxedOutStates.add(specState);
    }
  }

  void _updateMaxedOutStates() {
    for (int specId = 0; specId < _maxedOutStates.length; specId++) {
      for (int index = 0; index < _maxedOutStates[specId].length; index++) {
        if (isPositionEmptyAt(specId, index)) {
          _maxedOutStates[specId][index] = false;
        } else {
          _maxedOutStates[specId][index] = isTalentMaxedOutAt(specId, index);
        }
      }
    }
  }

  void _updateSpentPoints() {
    for (int specId = 0; specId < _spentPoints.length; specId++) {
      int sum = 0;
      for (int index = 0; index < _treeStates[specId].length; index++) {
        int indexValue = _treeStates[specId][index];
        if (indexValue >= 0) {
          sum += indexValue;
        }
      }
      _spentPoints[specId] = sum;
    }
  }

  String _buildPrintableSpecState(int specId) {
    String specState = _specPrintTemplates[specId];
    for (int talentState in _treeStates[specId]) {
      if (talentState < 0) {
        continue;
      }
      specState = specState.replaceFirst(RegExp('x'), talentState.toString());
    }

    return specState;
  }

  bool _isInputValidAt(int specId, int index) {
    if (!_isIndexValid(index)) {
      return false;
    }

    if (isPositionEmptyAt(specId, index)) {
      return false;
    }

    return true;
  }

  bool _isIndexValid(int index) => index >= 0 && index < _talentTreeLayouts[0].length;

  int _getPointsSumUpToRow(int specId, int row) {
    int sum = 0;

    for (int i = 0; i <= row; i++) {
      sum += _getRowSumFor(specId, i);
    }

    return sum;
  }

  int _getRowSumFor(int specId, int row) {
    int rowSum = 0;

    for (int i = 0; i < 4; i++) {
      int state = _treeStates[specId][row * 4 + i];
      if (state >= 0) {
        rowSum += state;
      }
    }

    return rowSum;
  }
}
