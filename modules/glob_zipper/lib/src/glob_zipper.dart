import "dart:async";
import "dart:convert";
import "dart:io";
import "dart:isolate";
import "dart:math";

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
  static final _random = Random();

  static Future<File> isolated({
    required Directory directory,
    Iterable<String> globPatterns = const ["**"],
    Iterable<String> ignorePatterns = const .empty(),
    String? ignoreFilename,
    int? level,
    String? password,
    Directory? tempDirectory,
    String? zipname,
    ZipCallback? onData,
    OnErrorCallback? onError,
  }) {
    return _zipInIsolate(
      directory: directory,
      globPatterns: globPatterns,
      ignoreFilename: ignoreFilename,
      ignorePatterns: ignorePatterns,
      level: level,
      password: password,
      tempDirectory: tempDirectory,
      zipname: zipname,
      onData: onData,
      onError: onError,
    );
  }

  const GlobZipper({
    required this.directory,
    this.globPatterns = const ["**"],
    this.ignorePatterns = const .empty(),
    this.ignoreFilename,
    this.level,
    this.password,
    this.tempDirectory,
    this.zipname,
  });

  final Directory directory;
  final Iterable<String> globPatterns;
  final Iterable<String> ignorePatterns;
  final String? ignoreFilename;
  final int? level;
  final String? password;
  final Directory? tempDirectory;
  final String? zipname;

  String get _zipname {
    if (zipname case final zname? when zname.isNotEmpty) return "$zname.zip";
    return ".temp-${_random.nextDouble()}.zip";
  }

  Future<File> zip({ZipCallback? onData, OnErrorCallback? onError}) async {
    final tempFilename = _zipname;

    final fs = FS(
      directory: directory,
      globPatterns: globPatterns,
      ignoreFilename: ignoreFilename,
      ignorePatterns: ignorePatterns.followedBy([tempFilename]),
    );

    final tempDirectory = this.tempDirectory ?? .systemTemp;

    final tempFilePath = joinAll([tempDirectory.path, tempFilename]);

    final File file = .new(tempFilePath);

    bool success = false;
    try {
      final encoder = ZipFileEncoder(password: password)
        ..create(tempFilePath, level: level);

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
      if (!success) await file.safeDelete();
    }

    return file;
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
