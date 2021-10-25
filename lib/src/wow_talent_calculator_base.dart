import 'package:wow_talent_calculator/src/utils/constants.dart';

class WoWTalentCalculator {
  final int expansionId;
  final int charClass;

  List<List<int>> _treeState = List.empty();

  WoWTalentCalculator({required this.expansionId, required this.charClass}) {
    assert(
        expansionId > 0 && expansionId < Constants.expansionIds.length, "Expansion ID cannot be less than 0 or greater than ${Constants.expansionIds.length}");
    _treeState = List.from(Constants.initialTreeState[expansion][charClass]);
  }
}
