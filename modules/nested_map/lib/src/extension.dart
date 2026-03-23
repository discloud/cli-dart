part of "nested_map.dart";

const _dot = ".";

extension MapExtension<K extends String> on Map<K, dynamic> {
  dynamic _nestedGet(List<K> keys) {
    return switch (this[keys.removeAt(0)]) {
      final Map<K, dynamic> map => map._nestedGet(keys),
      final value => value,
    };
  }

  void _nestedSet(List<K> keys, K lastKey, dynamic value) {
    if (keys.isEmpty) {
      this[lastKey] = value;
      return;
    }

    switch (putIfAbsent(keys.removeAt(0), () => <K, dynamic>{} as dynamic)) {
      case final Map<K, dynamic> map:
        map._nestedSet(keys, lastKey, value);
    }
  }

  T? get<T>(K key, [T? Function()? defaultFactory]) {
    return _nestedGet(key.split(_dot) as List<K>) ?? defaultFactory?.call();
  }

  void set(K key, dynamic value) {
    final keys = key.split(_dot) as List<K>;
    final lastKey = keys.removeLast();
    _nestedSet(keys, lastKey, value);
  }
}
