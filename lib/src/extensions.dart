extension ListCountExtension<T> on List {
  int count(T element) {
    var foundElements = where((letter) => letter == element);
    return foundElements.length;
  }
}
