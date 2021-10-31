import '../src/utils/extensions.dart';
import 'models/talent_tree_position.dart';
import 'utils/talent_calculator_constants.dart';

class WowTalentCalculator {
  int _expansionId = 0;
  int _charClassId = 0;
  int _specId = 0;

  int _maxTalentPoints = 0;

  List<List<int>> _treeStates = [];
  List<List<bool>> _availabilityStates = [];

  List<List<int>> _talentTreeLayouts = [];
  List<List<int>> _talentMaxPoints = [];
  List<List<int>> _talentDependencies = [];
  List<String> _specPrintTemplates = [];

  final List<int> _spentPoints = [0, 0, 0];

  /// Default constructor
  ///
  /// When no parameters are provided, [expansionId] and [charclassId] are both set to 0
  /// This means expansion will be Vanilla / Classic WoW and the character class will be Druid
  WowTalentCalculator({int expansionId = 0, int charClassId = 0}) {
    _expansionId = expansionId;
    _charClassId = charClassId;

    _maxTalentPoints = TalentCalculatorConstants.maxTalentPoints[_expansionId];

    _talentTreeLayouts = List.from(TalentCalculatorConstants.talentLayouts[_expansionId][_charClassId]);
    _talentMaxPoints = List.from(TalentCalculatorConstants.talentMaxPoints[_expansionId][_charClassId]);
    _talentDependencies = List.from(TalentCalculatorConstants.talentDependencies[_expansionId][_charClassId]);
    _specPrintTemplates = List.from(TalentCalculatorConstants.specPrintTemplates[_expansionId][_charClassId]);

    _createTreeState(_expansionId);
    _createAvailabilityStates(_expansionId);
    _initTreeState();
    _initAvailabilityStates();
  }

  // * ----------------- PUBLIC METHODS -----------------

  /// Invests a talent point in talent at [index]
  void investPointAt(int index) {
    if (!canInvestPointAt(index)) {
      return;
    }

    _treeStates[_specId][index]++;
    _spentPoints[_specId]++;
    _updateAvailabilityStates();
  }

  /// Removes a talent point from talent at [index]
  void removePointAt(int index) {
    if (!canRemovePointAt(index)) {
      return;
    }

    _treeStates[_specId][index]--;
    _spentPoints[_specId]--;
    _updateAvailabilityStates();
  }

  /// Checks whether or not it is possible to invest a talent point at [index]
  ///
  /// Checks whether or not all talent points are spent
  /// Checks whether or not input [index] is valid
  /// Checks whether or not the talent at [index] is available
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

  /// Checks whether or not removing from talent at [index] is possible
  ///
  /// Checks wheter or not the inpunt [index] is valid
  /// Checks whether or not the talent at [index] is available
  /// Checks whether or not it is safe to remove a point at [index]
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

  /// Returns true when talent at [index] is available
  ///
  /// Checks for minimum required spent points in current tree
  /// Checks for met dependencies
  bool isTalentAvailableAt(int index) {
    if (_spentPoints[_specId] < (index ~/ 4) * 5) {
      return false;
    }

    int dependencyTreeIndex = _talentDependencies[_specId][index];
    if (dependencyTreeIndex > 0) {
      int dependencyState = _treeStates[_specId][dependencyTreeIndex];
      int dependencyMaxState = _talentMaxPoints[_specId][dependencyTreeIndex];
      int dependencyRow = dependencyTreeIndex ~/ 4;

      if (dependencyState != dependencyMaxState || _spentPoints[_specId] < dependencyRow * 5) {
        return false;
      }
    }

    return true;
  }

  // Returns true when talent is maxed out
  bool isTalentMaxedOutAt(int index) {
    if (_treeStates[_specId][index] == _talentMaxPoints[_specId][index]) {
      return true;
    }

    return false;
  }

  /// Checks whether or not there is a talent at the specified tree index
  bool isPositionEmptyAt(int index) => _talentTreeLayouts[_specId][index] == 0;

  /// Checks wheter or not it is safe to remove a talent point at [index]
  ///
  /// Checks if dependent talent has points
  /// Checks if removing point would break dependency for the next tier
  /// Checks if removing point would break highest tier
  bool isSafeToRemovePointAt(int index) {
    if (_talentDependencies[_specId].contains(index)) {
      int dependentTalent = _talentDependencies[_specId].indexOf(index);
      if (_treeStates[_specId][dependentTalent] != 0) {
        return false;
      }
    }

    int pointsInThisTree = getSpentPoints(specId: _specId);
    int maxRows = TalentCalculatorConstants.maxTalentTreeRows[_expansionId];
    int currentRow = index ~/ 4;
    int highestRow = pointsInThisTree ~/ 5 >= maxRows ? maxRows - 1 : pointsInThisTree ~/ 5;
    int pointsSumUpToHighestRow = _getPointsSumUpToRow(highestRow);

    if (_getRowSumFor(currentRow) - 1 < (currentRow * 5) + 5) {
      return false;
    }

    if (pointsSumUpToHighestRow - 1 < highestRow * 5) {
      return false;
    }

    return true;
  }

  /// Returns true when [getSpentPoints] equals [_maxTalentPoints]
  bool areAllPointsSpent() {
    return getSpentPoints() == _maxTalentPoints;
  }

  /// Resets a spec
  ///
  /// If no [specId] is provided, the current set [_specId] will be reset
  void resetSpec({int specId = -1}) {
    int id = specId < 0 ? _specId : specId;
    for (int i = 0; i < _treeStates[id].length; i++) {
      if (_treeStates[id][i] < 0) {
        continue;
      }
      _spentPoints[id] -= _treeStates[id][i];
      _treeStates[id][i] = 0;
    }

    _updateAvailabilityStates(specId: id);
  }

  /// Resets all specs
  void resetAll() {
    for (int specId in TalentCalculatorConstants.expansionAndSpecIds) {
      resetSpec(specId: specId);
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
  ///
  /// If no [specId] is provided, the current [_specId] spec will be printed
  void printSpec([int specId = -1]) {
    print(_buildPrintableSpecState(specId < 0 ? _specId : specId));
  }

  // * ----------------- GETTER & SETTER -----------------

  int get getExpansionId => _expansionId;

  int get getCharClassId => _charClassId;

  int get getSpecId => _specId;

  List<List<int>> get getTreeState => _treeStates;

  List<bool> get getAvailabilityStates => _availabilityStates[_specId];

  bool getAvailabilityStateAt(int index) => _availabilityStates[_specId][index];

  int getSpentPoints({int specId = -1}) {
    if (specId == -1) {
      return _spentPoints.reduce((a, b) => a + b);
    }

    return _spentPoints[specId];
  }

  int getInvestedPointsAt(int index) {
    if (!_isIndexValid(index)) {
      return -1;
    }

    return _treeStates[_specId][index];
  }

  Position getPositionFor(int index) => Position(row: index ~/ 4, column: index % 4);

  int getDependeesAmount(int index) => _talentDependencies[_specId].count(index);

  set setSpecId(int specId) => _specId = specId;

  set setTreeState(List<List<int>> treeState) => _treeStates = treeState;

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

  void _initAvailabilityStates() {
    for (int i = 0; i < _availabilityStates.length; i++) {
      for (int j = 0; j < _availabilityStates[i].length; j++) {
        if (_isInputValidAt(j)) {
          _availabilityStates[i][j] = isTalentAvailableAt(j);
        }
      }
    }
  }

  void _updateAvailabilityStates({int specId = -1}) {
    int id = specId < 0 ? _specId : specId;
    for (int i = 0; i < _availabilityStates[id].length; i++) {
      if (_isInputValidAt(i)) {
        _availabilityStates[id][i] = isTalentAvailableAt(i);
      } else {
        _availabilityStates[id][i] = false;
      }
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

  bool _isInputValidAt(int index) {
    if (!_isIndexValid(index)) {
      return false;
    }

    if (isPositionEmptyAt(index)) {
      return false;
    }

    return true;
  }

  bool _isIndexValid(int index) => index >= 0 && index < _talentTreeLayouts[0].length;

  int _getPointsSumUpToRow(int row) {
    int sum = 0;

    for (int i = 0; i < row; i++) {
      sum += _getRowSumFor(i);
    }

    return sum;
  }

  int _getRowSumFor(int row) {
    int rowSum = 0;

    for (int i = 0; i < 4; i++) {
      int state = _treeStates[_specId][row * 4 + i];
      if (state >= 0) {
        rowSum += state;
      }
    }

    return rowSum;
  }
}
