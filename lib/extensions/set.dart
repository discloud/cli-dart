extension SetExtension<E> on Set<E> {
  /// [forceAddOrRemove] is opitional and determines the behavior of the [toggle]
  ///
  /// - toggle(E) -> toggle [E]
  /// - toggle(E, true) -> force add [E]
  /// - toggle(E, false) -> force remove [E]
  bool toggle(E value, [bool? forceAddOrRemove]) {
    return switch (forceAddOrRemove) {
      null => remove(value) || add(value),
      false => remove(value),
      true => add(value),
    };
  }
}
