import "dart:async";
import "dart:convert";
import "dart:io";
import "dart:isolate";

import "package:archive/archive_io.dart";
import "package:glob/glob.dart";
import "package:glob/list_local_fs.dart";
import "package:glob_zipper/src/extensions/date_time.dart";
import "package:glob_zipper/src/extensions/file.dart";
import "package:path/path.dart";

part "exception.dart";
part "fs.dart";
part "gitignore_glob_converter.dart";
part "isolated.dart";
part "zip_progress.dart";

void _noop(_, _) {}

typedef ZipCallback = void Function(ZipProgress progress);
typedef OnErrorCallback = void Function(Object error, StackTrace trace);

class GlobZipper {
  static Future<void> isolated({
    required Directory directory,
    required File zipfile,
    Iterable<String> globPatterns = const ["**"],
    Iterable<String> ignorePatterns = const .empty(),
    String? ignoreFilename,
    int? level,
    String? password,
    ZipCallback? onData,
    OnErrorCallback? onError,
  }) => _zipInIsolate(
    directory: directory,
    zipfile: zipfile,
    globPatterns: globPatterns,
    ignoreFilename: ignoreFilename,
    ignorePatterns: ignorePatterns,
    level: level,
    password: password,
    onData: onData,
    onError: onError,
  );

  const GlobZipper({
    required this.directory,
    required this.zipfile,
    this.globPatterns = const ["**"],
    this.ignorePatterns = const .empty(),
    this.ignoreFilename,
    this.level,
    this.password,
  });

  final Directory directory;
  final File zipfile;
  final Iterable<String> globPatterns;
  final Iterable<String> ignorePatterns;
  final String? ignoreFilename;

  /// Compression level
  final int? level;
  final String? password;

  Future<void> zip({ZipCallback? onData, OnErrorCallback? onError}) async {
    final fs = FS(
      directory: directory,
      globPatterns: globPatterns,
      ignoreFilename: ignoreFilename,
      ignorePatterns: ignorePatterns.followedBy([zipfile.path]),
    );

    bool success = false;
    try {
      // Resolve the real root once so symlinked files cannot escape it.
      final rootPath = await directory.resolveSymbolicLinks();
      final encoder = ZipFileEncoder(password: password)
        ..create(zipfile.path, level: level);

      if (onData case final onData?) {
        await _zipWithCallback(encoder, fs.list, onData, rootPath, onError);
      } else {
        await _zipWithoutCallback(encoder, fs.list, rootPath, onError);
      }

      await encoder.close();

      success = true;
    } on PathAccessException catch (e, s) {
      if (onError == null) rethrow;
      onError(e, s);
    } finally {
      if (!success) await zipfile.safeDelete();
    }
  }

  Future<void> _zipWithoutCallback(
    ZipFileEncoder encoder,
    Stream<File> Function() fileStreamFactory, [
    String? rootPath,
    OnErrorCallback? onError,
  ]) async {
    await for (final file in fileStreamFactory().handleError(
      onError ?? _noop,
    )) {
      final aFile = await _toArchiveFile(
        file,
        root: directory,
        rootPath: rootPath,
      );

      encoder.addArchiveFile(aFile);
    }
  }

  Future<void> _zipWithCallback(
    ZipFileEncoder encoder,
    Stream<File> Function() fileStreamFactory,
    ZipCallback onData, [
    String? rootPath,
    OnErrorCallback? onError,
  ]) async {
    int processed = 0, i = 0;
    await for (final file in fileStreamFactory().handleError(
      onError ?? _noop,
    )) {
      await _ensureInsideRoot(file, directory, rootPath);
      final stat = await file.stat();

      onData(
        .new(
          file: file,
          stat: stat,
          current: ++i,
          processed: processed,
          compressed: await zipfile.length(),
        ),
      );

      final aFile = await _toArchiveFile(
        file,
        root: directory,
        rootPath: rootPath,
        stat: stat,
        trusted: true,
      );

      encoder.addArchiveFile(aFile);

      processed += stat.size;
    }
  }

  Future<ArchiveFile> _toArchiveFile(
    File file, {
    required Directory root,
    String? rootPath,
    FileStat? stat,
    bool trusted = false,
  }) async {
    if (!trusted) await _ensureInsideRoot(file, root, rootPath);

    stat ??= await file.stat();

    final filename = relative(file.path, from: root.path);

    final InputFileStream fileStream = .new(file.path);

    return .stream(filename, fileStream)
      ..compressionLevel = level
      ..lastModTime = stat.modified.secondsSinceEpoch
      ..mode = stat.mode;
  }

  Future<void> _ensureInsideRoot(
    File file,
    Directory root,
    String? rootPath,
  ) async {
    rootPath ??= await root.resolveSymbolicLinks();
    final filePath = await file.resolveSymbolicLinks();

    if (equals(rootPath, filePath) || isWithin(rootPath, filePath)) return;

    throw FileSystemException(
      "Refusing to zip a file outside the root directory",
      file.path,
    );
  }
}
