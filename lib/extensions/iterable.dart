extension IterableEnumExtension<E extends Enum> on Iterable<E> {
  E byNameOrFirst(String name) => byNameOrNull(name) ?? first;

  E? byNameOrNull(String name) {
    try {
      return byName(name);
    } catch (_) {
      return null;
    }
  }
}

extension IterableNumExtension<E extends num> on Iterable<E> {
  E sum() => reduce((a, b) => a + b as E);
}
