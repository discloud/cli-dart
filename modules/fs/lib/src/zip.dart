import "dart:async";
import "dart:io";
import "dart:math";

import "package:archive/archive_io.dart";
import "package:fs/src/fs.dart";
import "package:fs/src/zip_progress.dart";
import "package:path/path.dart";

typedef ZipCallback = Future<void> Function(ZipProgress progress);

class Zipper {
  // ignore: constant_identifier_names
  static const _1e6 = 1e6;
  static const _dot = ".";
  static const _empty = "";
  static final _random = Random();

  const Zipper({
    required this.directory,
    this.patterns = const ["**"],
    this.ignore = const .empty(),
    this.ignoreFilename,
    this.tempDirectory,
    this.tempFilenamePrefix = "file",
  });

  final Directory directory;
  final Iterable<String> patterns;
  final Iterable<String> ignore;
  final String? ignoreFilename;
  final Directory? tempDirectory;
  final String tempFilenamePrefix;

  Future<File> zip([ZipCallback? callback]) async {
    final fs = FS(
      directory: directory,
      patterns: patterns,
      ignoreFilename: ignoreFilename,
      ignore: ignore,
    );

    final tempDirectory = this.tempDirectory ?? .systemTemp;

    final random = "${_random.nextDouble()}".replaceAll(_dot, _empty);

    final tempFilename = "$tempFilenamePrefix-$random.zip";

    final tempFilePath = joinAll([tempDirectory.path, tempFilename]);

    final encoder = ZipFileEncoder()..create(tempFilePath);

    final stream = fs.list().where((file) => file.path != tempFilePath);

    if (callback case final callback?) {
      await _zipWithCallback(encoder, stream, callback);
    } else {
      await _zipWithoutCallback(encoder, stream);
    }

    await encoder.close();

    return .new(tempFilePath);
  }

  Future<void> _zipWithoutCallback(
    ZipFileEncoder encoder,
    Stream<File> stream,
  ) async {
    await for (final file in stream) {
      final stat = await file.stat();

      final aFile = await _toArchiveFile(file, root: directory, stat: stat);

      encoder.addArchiveFile(aFile);
    }
  }

  Future<void> _zipWithCallback(
    ZipFileEncoder encoder,
    Stream<File> stream,
    ZipCallback callback,
  ) async {
    final list = await stream.toList();

    int i = 1;
    int processed = 0;
    for (final file in list) {
      final stat = await file.stat();

      unawaited(
        callback(
          .new(
            file: file,
            stat: stat,
            current: i++,
            total: list.length,
            processed: processed += stat.size,
          ),
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
      ..lastModTime = stat.modified.microsecondsSinceEpoch ~/ _1e6
      ..mode = stat.mode;

    return archiveFile;
  }
}
