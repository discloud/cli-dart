part of "glob_zipper.dart";

const _dot = ".";
const _empty = "";
const _gStar = "**";
const _gSep = ",";
const _pSep = "/";
const _rSlash = r"\";

void _noop(_, _) {}

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

  Glob get _ignoreGlob {
    try {
      return .new(_transformIterableGlobToGlobPattern(_ignorePatterns));
    } catch (_) {
      return .new("_ignore_${DateTime.now().microsecondsSinceEpoch}_glob_");
    }
  }

  Stream<File> list() {
    if (ignoreFilename case final fname?) return _listWithIgnoreFilename(fname);
    return _listWithoutIgnoreFilename();
  }

  Stream<File> _listWithIgnoreFilename(String filename) async* {
    Glob ignore = _ignoreGlob;

    final visitedDirectories = <String>{};

    await for (final entity
        in _glob.list(root: directory.path).handleError(_noop)) {
      if (entity is! File) continue;

      final folder = entity.dirname;
      if (!visitedDirectories.contains(folder)) {
        visitedDirectories.add(folder);

        await _resolveIgnoreFile(folder, filename);

        ignore = _ignoreGlob;
      }

      if (ignore.matches(entity.path)) continue;

      yield entity as File;
    }
  }

  Stream<File> _listWithoutIgnoreFilename() async* {
    final Glob ignore = _ignoreGlob;

    await for (final entity
        in _glob.list(root: directory.path).handleError(_noop)) {
      if (entity is! File || ignore.matches(entity.path)) continue;

      yield entity as File;
    }
  }

  Future<void> _resolveIgnoreFile(String folder, String filename) async {
    final File file = .new("$folder$_pSep$filename");

    if (!await file.exists()) return;

    String ignorePattern = await _gitignoreFileToGlobConverter(file);

    final relativePath = dirname(relative(file.path, from: directory.path));

    if (relativePath != _dot) {
      ignorePattern = "${_normalizeGlobPath(relativePath)}$_pSep$ignorePattern";
    }

    _ignorePatterns.add(ignorePattern);
  }
}
