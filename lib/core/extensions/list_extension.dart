extension ListExtension<T> on List<T> {
  ///Merge to many list as we wants in a same list
  void merge(List<List<T>> listToAdd) {
    int i = 0;
    while (i < listToAdd.length) {
      addAll(listToAdd.elementAt(i));
      i++;
    }
  }

  ///Ignore the item if predicate match
  List<T> ignoreWhile({required bool Function(T predicate) ignoreIf}) {
    List<T> cache = <T>[];
    for (int i = 0; i < length; i++) {
      final T element = elementAt(i);
      if (ignoreIf(element)) continue;
      cache.add(element);
    }
    return cache;
  }

  ///Count the items that matches with yout object data, or use predicate to match
  int count(T obj, {bool Function(T)? predicate}) {
    int count = 0, i = 0;
    while (i < length) {
      final T found = elementAt(i);
      if (found == obj) {
        count++;
      } else if (predicate != null && predicate(found)) {
        count++;
      }
      i++;
    }
    return count;
  }

  ///Verify if a element exist using a predicate that match
  bool exist({required bool Function(T reference) predicate}) {
    for (T value in this) {
      if (predicate(value)) {
        return true;
      }
    }
    return where((dynamic element) => predicate(element)).firstOrNull != null;
  }
}
