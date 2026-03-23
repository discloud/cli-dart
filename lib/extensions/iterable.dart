import "dart:math";

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
  static E _sum<E extends num>(E a, E b) => a + b as E;

  E highest() => isEmpty ? 0 as E : reduce(max);

  E lowest() => isEmpty ? 0 as E : reduce(min);

  E sum() => isEmpty ? 0 as E : reduce(_sum);
}
