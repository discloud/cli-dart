import "dart:io";
import "dart:isolate";

import "package:glob_zipper/glob_zipper.dart";

const _ignoreFilename = ".discloudignore";

Future<File> zip({
  required Directory directory,
  Iterable<String> glob = const ["**"],
  Iterable<String> ignore = const .empty(),
}) {
  return Isolate.run(() {
    final zipper = GlobZipper(
      directory: directory,
      tempDirectory: directory,
      globPatterns: glob,
      ignorePatterns: ignore,
      ignoreFilename: _ignoreFilename,
    );

    return zipper.zip();
  });
}
