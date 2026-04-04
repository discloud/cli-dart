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

  Glob get _ignoreGlob =>
      .new(_transformIterableGlobToGlobPattern(_ignorePatterns));

  Stream<File> list() async* {
    Glob ignore = _ignoreGlob;

    final visitedDirectories = <String>{};

    await for (final entity
        in _glob.list(root: directory.path).handleError(_noop)) {
      if (entity is! File) continue;

      if (ignoreFilename case final filename?) {
        final dir = entity.dirname;

        if (!visitedDirectories.contains(dir)) {
          visitedDirectories.add(dir);

          final ignoreFilePath = joinAll([dir, filename]);

          final ignoreFile = File(ignoreFilePath);

          await _resolveIgnoreFile(ignoreFile);

          ignore = _ignoreGlob;
        }

        if (ignore.matches(entity.path)) continue;
      }

      yield entity as File;
    }
  }

  Future<void> _resolveIgnoreFile(File file) async {
    if (!await file.exists()) return;

    String ignorePattern = await _gitignoreFileToGlobConverter(file);

    final relativePath = dirname(relative(file.path, from: directory.path));

    if (relativePath != _dot) {
      ignorePattern = "${_normalizeGlobPath(relativePath)}$_pSep$ignorePattern";
    }

    _ignorePatterns.add(ignorePattern);
  }
}
