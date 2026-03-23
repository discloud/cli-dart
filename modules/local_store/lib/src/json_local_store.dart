part of "local_store.dart";

class _JSONLocalStore implements LocalStore {
  _JSONLocalStore(this.path);

  final String path;
  late final File _file = .new(path);

  final cache = <String, dynamic>{};

  bool _loaded = false;

  Future<void> _load() async {
    if (_loaded) return;
    try {
      final encoded = await _file.readAsString();
      final decoded = base64Decode(encoded);
      final text = String.fromCharCodes(decoded);
      final Map<String, dynamic> json = jsonDecode(text);
      cache.addAll(json..addAll(cache));
    } catch (_) {
    } finally {
      _loaded = true;
    }
  }

  Future<void> _save() async {
    final text = jsonEncode(cache);
    final encoded = base64Encode(text.codeUnits);
    await _file.create(recursive: true);
    await _file.writeAsString(encoded);
  }

  @override
  Future<T?> get<T>(String key) async {
    await _load();
    return cache.get(key);
  }

  @override
  Future<void> set(String key, value) async {
    await _load();
    cache.set(key, value);
    await _save();
  }
}
