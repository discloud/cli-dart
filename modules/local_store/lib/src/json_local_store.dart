part of "local_store.dart";

class _JSONLocalStore implements LocalStore {
  static final _jsonBase64Decoder = utf8.decoder
      .fuse(base64.decoder)
      .fuse(utf8.decoder)
      .fuse(json.decoder);

  static final _jsonBase64Encoder = json.encoder
      .fuse(utf8.encoder)
      .fuse(base64.encoder);

  _JSONLocalStore(this.path);

  final String path;
  late final File _file = .new(path);

  final _cache = <String, dynamic>{};

  Completer<void>? _loadCompleter;

  Future<void> _load() async {
    if (_loadCompleter case final completer?) return completer.future;
    final completer = _loadCompleter = .new();
    try {
      final json =
          await _file.openRead().transform(_jsonBase64Decoder).first
              as Map<String, dynamic>;
      _cache.addAll(json..addAll(_cache));
    } catch (_) {
    } finally {
      completer.complete();
      if (completer != _loadCompleter) _loadCompleter?.complete();
    }
  }

  Future<void> _save() async {
    if (!await _file.exists()) await _file.create(recursive: true);
    await _file.writeAsString(_jsonBase64Encoder.convert(_cache), flush: true);
  }

  @override
  Future<T?> get<T>(String key) async {
    await _load();
    return _cache.get(key);
  }

  @override
  Stream<T?> getMany<T>(Iterable<String> keys) async* {
    await _load();
    for (final key in keys) {
      yield _cache.get(key);
    }
  }

  @override
  Future<void> set(String key, value) async {
    await _load();
    _cache.set(key, value);
    await _save();
  }
}
