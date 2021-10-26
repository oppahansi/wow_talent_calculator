class TalentCalculatorException implements Exception {
  final String cause;
  TalentCalculatorException(this.cause);

  @override
  String toString() => cause;
}
