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
    this.globPatterns = const ["**"],
    this.ignoreFilename,
    Iterable<String> ignorePatterns = const .empty(),
  }) : _glob = .new(
         _transformIterableGlobToGlobPattern(
           _transformIterableToGlob(globPatterns),
         ),
       ),
       _originalIgnorePatterns = _transformIterableToGlob(
         ignorePatterns,
       ).toSet() {
    _ignorePatterns = _originalIgnorePatterns.toSet();
  }

  final Directory directory;
  final Iterable<String> globPatterns;
  late final Glob _glob;
  final String? ignoreFilename;
  late final Set<String> _ignorePatterns;
  final Set<String> _originalIgnorePatterns;

  Glob get _ignoreGlob =>
      .new(_transformIterableGlobToGlobPattern(_ignorePatterns));

  String? get _ignoreFilePattern {
    if (ignoreFilename case final filename?) return "$_gStar$filename";
    return null;
  }

  Stream<File> list() async* {
    await _findIgnoreFiles();

    final ignore = _ignoreGlob;

    await for (final entity in _glob.list(root: directory.path)) {
      if (entity is! File) continue;
      if (ignore.matches(entity.path)) continue;

      yield entity as File;
    }
  }

  Future<void> _findIgnoreFiles() async {
    final ignoreFilePattern = _ignoreFilePattern;
    if (ignoreFilePattern == null) return;

    _ignorePatterns
      ..clear()
      ..addAll(_originalIgnorePatterns);

    final glob = Glob(ignoreFilePattern);
    Glob ignore = _ignoreGlob;

    await for (final entity in glob.list(root: directory.path)) {
      if (entity is! File) continue;
      if (ignore.matches(entity.path)) continue;
      if (basename(entity.path) != ignoreFilename) continue;

      String ignorePattern = await _gitignoreFileToGlobConverter(
        entity as File,
      );

      final relativePath = dirname(relative(entity.path, from: directory.path));

      if (relativePath != _dot) {
        ignorePattern =
            "${_normalizeGlobPath(relativePath)}$_pSep$ignorePattern";
      }

      _ignorePatterns.add(ignorePattern);

      ignore = _ignoreGlob;
    }
  }
}
