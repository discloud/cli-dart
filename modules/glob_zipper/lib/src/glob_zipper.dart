import "dart:async";
import "dart:convert";
import "dart:io";
import "dart:isolate";

import "package:archive/archive_io.dart";
import "package:glob/glob.dart";
import "package:glob/list_local_fs.dart";
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
  // ignore: constant_identifier_names
  static const _1e6 = 1e6;

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
  }) {
    return _zipInIsolate(
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
  }

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
      final encoder = ZipFileEncoder(password: password)
        ..create(zipfile.path, level: level);

      if (onData case final onData?) {
        await _zipWithCallback(encoder, fs.list, onData, onError);
      } else {
        await _zipWithoutCallback(encoder, fs.list, onError);
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
    OnErrorCallback? onError,
  ]) async {
    onError ??= _noop;
    await for (final file in fileStreamFactory().handleError(onError)) {
      final aFile = await _toArchiveFile(file, root: directory);

      encoder.addArchiveFile(aFile);
    }
  }

  Future<void> _zipWithCallback(
    ZipFileEncoder encoder,
    Stream<File> Function() fileStreamFactory,
    ZipCallback onData, [
    OnErrorCallback? onError,
  ]) async {
    onError ??= _noop;
    int processed = 0, i = 1;
    await for (final file in fileStreamFactory().handleError(onError)) {
      final stat = await file.stat();

      onData(
        .new(
          file: file,
          stat: stat,
          current: i++,
          processed: processed += stat.size,
        ),
      );

      final aFile = await _toArchiveFile(file, root: directory, stat: stat);

      encoder.addArchiveFile(aFile);
    }
  }

  Future<ArchiveFile> _toArchiveFile(
    File file, {
    required Directory root,
    FileStat? stat,
  }) async {
    stat ??= await file.stat();

    final filename = relative(file.path, from: root.path);

    final fileStream = InputFileStream(file.path);

    final archiveFile = ArchiveFile.stream(filename, fileStream)
      ..compressionLevel = level
      ..lastModTime = stat.modified.microsecondsSinceEpoch ~/ _1e6
      ..mode = stat.mode;

    return archiveFile;
  }
}
