class Position {
  final int row;
  final int column;

  Position({
    required this.row,
    required this.column,
  });

  @override
  String toString() {
    return "$row|$column";
  }
}
