import "dart:io";

import "package:discloud/utils/bytes.dart";
import "package:glob_zipper/glob_zipper.dart";
import "package:path/path.dart";

const _ignoreFilename = ".discloudignore";

Future<void> zip({
  required Directory directory,
  required File zipfile,
  Iterable<String> glob = const ["**"],
  Iterable<String> ignore = const .empty(),
  ZipCallback? onData,
  OnErrorCallback? onError,
}) {
  return GlobZipper.isolated(
    directory: directory,
    zipfile: zipfile,
    globPatterns: glob,
    ignorePatterns: ignore,
    ignoreFilename: _ignoreFilename,
    onData: onData,
    onError: onError,
  );
}

String formatZipProgress(ZipProgress progress, Directory root) {
  final buffer = StringBuffer("Zipping...")
    ..writeAll([
      "\n[${progress.current}]:",
      "(${Bytes(progress.stat.size)})",
      relative(progress.file.path, from: root.path),
    ], " ");

  return buffer.toString();
}
