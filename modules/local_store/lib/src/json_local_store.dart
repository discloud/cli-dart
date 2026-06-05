part of "local_store.dart";

class _JSONLocalStore implements LocalStore {
  static final Converter<List<int>, Object?> _jsonBase64Decoder = utf8.decoder
      .fuse(base64.decoder)
      .fuse(utf8.decoder)
      .fuse(json.decoder);

  static final Converter<Object?, List<int>> _jsonBase64Encoder = json.encoder
      .fuse(utf8.encoder)
      .fuse(base64.encoder)
      .fuse(utf8.encoder);

  _JSONLocalStore(this.path) : _cache = .new(), _file = .new(path);

  final String path;

  final Map<String, dynamic> _cache;
  final File _file;

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
    }
  }

  Future<void> _save() async {
    if (!await _file.exists()) await _file.create(recursive: true);
    await _file.writeAsBytes(_jsonBase64Encoder.convert(_cache), flush: true);
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
