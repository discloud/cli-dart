part of "glob_zipper.dart";

const _gStar = "**";
const _gSep = ",";
const _pSep = "/";
const _dot = ".";
const _rSlash = r"\";
const _empty = "";

class FS {
  static String _normalizeGlobPath(String path) {
    return path.replaceAll(_rSlash, _pSep);
  }

  FS({
    required this.directory,
    this.patterns = const ["**"],
    this.ignoreFilename,
    Iterable<String> ignore = const .empty(),
  }) : _originalIgnore = transformIterableToGlob(ignore).toSet() {
    _ignore = _originalIgnore.toSet();
  }

  final Directory directory;
  final Iterable<String> patterns;
  final String? ignoreFilename;
  late final Set<String> _ignore;
  final Set<String> _originalIgnore;

  Iterable<Glob> get _ignoreIterableGlob => _ignore.map(Glob.new);

  String? get _ignoreFilePattern {
    if (ignoreFilename case final filename?) return "$_gStar$_pSep$filename";
    return null;
  }

  Stream<File> list() async* {
    await _findIgnoreFiles();

    final glob = Glob(_gStar);

    final ignore = _ignoreIterableGlob;
    final globs = patterns.map(Glob.new);

    await for (final entity in glob.list(root: directory.path)) {
      if (entity is! File) continue;
      if (!globs.any((g) => g.matches(entity.path))) continue;
      if (ignore.any((g) => g.matches(entity.path))) continue;

      yield entity as File;
    }
  }

  Future<void> _findIgnoreFiles() async {
    final ignoreFilePattern = _ignoreFilePattern;
    if (ignoreFilePattern == null) return;

    _ignore
      ..clear()
      ..addAll(_originalIgnore);

    final glob = Glob(ignoreFilePattern);
    Iterable<Glob> ignore = _ignoreIterableGlob;

    await for (final entity in glob.list(root: directory.path)) {
      if (entity is! File) continue;
      if (ignore.any((g) => g.matches(entity.path))) continue;

      final ignorePattern = await gitignoreFileToGlobConverter(entity as File);
      final relativePath = dirname(relative(entity.path, from: directory.path));

      if (relativePath == _dot) {
        _ignore.add(ignorePattern);
      } else {
        _ignore.add("${_normalizeGlobPath(relativePath)}$_pSep$ignorePattern");
      }

      ignore = _ignoreIterableGlob;
    }
  }
}
