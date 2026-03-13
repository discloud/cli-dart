import "dart:io";

import "package:fs/src/gitignore_glob_converter.dart";
import "package:glob/glob.dart";
import "package:glob/list_local_fs.dart";
import "package:path/path.dart";

class FS {
  static const _globStar = "**";
  static const _sep = "/";
  static const _dot = ".";
  static const _rSlash = r"\";

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
    if (ignoreFilename case final filename?) return "$_globStar$_sep$filename";
    return null;
  }

  Stream<File> list() async* {
    await _findIgnoreFiles();

    final glob = Glob(_globStar);

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
        _ignore.add(
          "${relativePath.replaceAll(_rSlash, _sep)}$_sep$ignorePattern",
        );
      }

      ignore = _ignoreIterableGlob;
    }
  }
}
