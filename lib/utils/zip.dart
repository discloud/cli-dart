import "dart:io";

import "package:discloud/utils/bytes.dart";
import "package:glob_zipper/glob_zipper.dart";
import "package:path/path.dart";

const _ignoreFilename = ".discloudignore";

Future<File> zip({
  required Directory directory,
  Iterable<String> glob = const ["**"],
  Iterable<String> ignore = const .empty(),
  ZipCallback? callback,
  String? zipname,
}) {
  return GlobZipper.isolated(
    directory: directory,
    tempDirectory: directory,
    globPatterns: glob,
    ignorePatterns: ignore,
    ignoreFilename: _ignoreFilename,
    onData: callback,
    zipname: zipname,
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
