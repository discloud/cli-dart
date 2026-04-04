import "dart:async";
import "dart:convert";
import "dart:io";

import "package:nested_map/nested_map.dart";

part "json_local_store.dart";

abstract class LocalStore {
  factory LocalStore.json(String path) = _JSONLocalStore;

  Future<T?> get<T>(String key);
  Stream<T?> getMany<T>(Iterable<String> keys);
  Future<void> set(String key, dynamic value);
}
