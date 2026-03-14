import "dart:io";

import "package:args/command_runner.dart";
import "package:fs/fs.dart";
import "package:path/path.dart";

class ZipCommand extends Command<void> {
  ZipCommand() {
    argParser
      ..addOption("encoding", abbr: "e", allowed: ["buffer"])
      ..addMultiOption("glob", abbr: "g", defaultsTo: ["**"])
      ..addOption("out", abbr: "o");
  }

  @override
  final name = "zip";

  @override
  final description = "Make zip";

  @override
  Future<void> run() async {
    final Directory directory = .current;

    final out = argResults?.option("out");

    final zipper = Zipper(
      directory: directory,
      tempDirectory: out == null ? null : directory,
      patterns: argResults?.multiOption("glob") ?? const ["**"],
      ignoreFilename: ".discloudignore",
    );

    final file = await zipper.zip();

    switch (argResults?.option("encoding")) {
      case "buffer":
        await stdout.addStream(file.openRead());
        await file.delete();
        return;
    }

    final filename = out ?? "${basenameWithoutExtension(directory.path)}.zip";

    await file.rename(joinAll([directory.path, filename]));
  }
}
