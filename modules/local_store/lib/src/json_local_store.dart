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

  static Future<void> _loadCache(Map<String, dynamic> cache, File file) async {
    try {
      final json =
          await file.openRead().transform(_jsonBase64Decoder).first
              as Map<String, dynamic>;
      cache.addAll(json..addAll(cache));
    } catch (_) {}
  }

  factory(String path) => ._(cache: .new(), file: .new(path));

  new _({required this._cache, required this._file});

  final Map<String, dynamic> _cache;
  final File _file;

  Future<void>? _loadFuture;
  Future<void> _load() => _loadFuture ??= _loadCache(_cache, _file);

  Future<void> _save() async {
    await _file.parent.create(recursive: true);

    final File temp = .new("${_file.path}.tmp");
    await temp.writeAsBytes(_jsonBase64Encoder.convert(_cache), flush: true);

    await temp.rename(_file.path);
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
