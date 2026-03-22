part of "nested_map.dart";

const _dot = ".";

extension MapExtension<K extends String> on Map<K, dynamic> {
  dynamic _nestedGet(List<K> nestedKeys) {
    return switch (this[nestedKeys.removeAt(0)]) {
      final Map<K, dynamic> map => map._nestedGet(nestedKeys),
      final value => value,
    };
  }

  void _nestedSet(List<K> nestedKeys, K lastKey, dynamic value) {
    if (nestedKeys.isEmpty) {
      this[lastKey] = value;
      return;
    }

    switch (putIfAbsent(
      nestedKeys.removeAt(0),
      () => <K, dynamic>{} as dynamic,
    )) {
      case final Map<K, dynamic> map:
        map._nestedSet(nestedKeys, lastKey, value);
    }
  }

  T? get<T>(K key, [T? defaultValue]) {
    return _nestedGet(key.split(_dot) as List<K>) ?? defaultValue;
  }

  void set(K key, dynamic value) {
    final keys = key.split(_dot) as List<K>;
    final lastKey = keys.removeLast();
    _nestedSet(keys, lastKey, value);
  }
}
