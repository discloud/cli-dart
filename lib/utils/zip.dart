import "dart:io";
import "dart:isolate";

import "package:glob_zipper/glob_zipper.dart";

Future<File> zip({
  required Directory directory,
  Iterable<String> glob = const ["**"],
  Iterable<String> ignore = const .empty(),
}) async {
  return Isolate.run(() async {
    final zipper = GlobZipper(
      directory: directory,
      tempDirectory: directory,
      patterns: glob,
      ignore: ignore,
      ignoreFilename: ".discloudignore",
    );

    return zipper.zip();
  });
}
