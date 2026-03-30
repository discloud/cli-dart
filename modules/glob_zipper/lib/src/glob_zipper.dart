import "dart:async";
import "dart:convert";
import "dart:io";
import "dart:math";

import "package:archive/archive_io.dart";
import "package:glob/glob.dart";
import "package:glob/list_local_fs.dart";
import "package:path/path.dart";

part "fs.dart";
part "gitignore_glob_converter.dart";
part "zip_progress.dart";

typedef ZipCallback = Future<void> Function(ZipProgress progress);

class GlobZipper {
  // ignore: constant_identifier_names
  static const _1e6 = 1e6;
  static final _random = Random();

  const GlobZipper({
    required this.directory,
    this.globPatterns = const ["**"],
    this.ignorePatterns = const .empty(),
    this.ignoreFilename,
    this.tempDirectory,
    this.zipname,
  });

  final Directory directory;
  final Iterable<String> globPatterns;
  final Iterable<String> ignorePatterns;
  final String? ignoreFilename;
  final Directory? tempDirectory;
  final String? zipname;

  String get _zipname {
    if (zipname case final zipname? when zipname.isNotEmpty) return zipname;
    return "temp-${_random.nextDouble()}.zip";
  }

  Future<File> zip([ZipCallback? callback]) async {
    final tempFilename = _zipname;

    final fs = FS(
      directory: directory,
      globPatterns: globPatterns,
      ignoreFilename: ignoreFilename,
      ignorePatterns: ignorePatterns.followedBy([tempFilename]),
    );

    final tempDirectory = this.tempDirectory ?? .systemTemp;

    final tempFilePath = joinAll([tempDirectory.path, tempFilename]);

    final encoder = ZipFileEncoder()..create(tempFilePath);

    if (callback case final callback?) {
      await _zipWithCallback(encoder, fs.list(), callback);
    } else {
      await _zipWithoutCallback(encoder, fs.list());
    }

    await encoder.close();

    return .new(tempFilePath);
  }

  Future<void> _zipWithoutCallback(
    ZipFileEncoder encoder,
    Stream<File> stream,
  ) async {
    await for (final file in stream) {
      final aFile = await _toArchiveFile(file, root: directory);

      encoder.addArchiveFile(aFile);
    }
  }

  Future<void> _zipWithCallback(
    ZipFileEncoder encoder,
    Stream<File> stream,
    ZipCallback callback,
  ) async {
    int processed = 0, i = 1;
    await for (final file in stream) {
      final stat = await file.stat();

      unawaited(
        callback(
          .new(
            file: file,
            stat: stat,
            current: i++,
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
