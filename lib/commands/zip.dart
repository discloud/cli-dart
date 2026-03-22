import "dart:io";
import "dart:isolate";

import "package:args/command_runner.dart";
import "package:cli_spin/cli_spin.dart";
import "package:discloud/services/discloud/constants.dart";
import "package:glob_zipper/glob_zipper.dart";
import "package:path/path.dart";

class ZipCommand extends Command<void> {
  ZipCommand() {
    argParser
      ..addOption("encoding", abbr: "e", allowed: const ["buffer"])
      ..addMultiOption("glob", abbr: "g", defaultsTo: const ["**"])
      ..addOption("out", abbr: "o");
  }

  @override
  final name = "zip";

  @override
  final description = "Make zip";

  @override
  Future<void> run() async {
    final Directory directory = .current;

    final encoding = argResults?.option("encoding");
    final out = argResults?.option("out");
    final glob = argResults?.multiOption("glob") ?? const ["**"];

    final spinner = CliSpin(text: "Zipping...").start();

    final file = await Isolate.run(() async {
      final zipper = GlobZipper(
        directory: directory,
        tempDirectory: encoding == null ? directory : null,
        patterns: glob,
        ignore: allBlockedFiles,
        ignoreFilename: ".discloudignore",
      );

      return zipper.zip();
    });

    spinner.success("Success!");

    switch (encoding) {
      case "buffer":
        await stdout.addStream(file.openRead());
        await file.delete();
        return;
    }

    final filename = out ?? "${basenameWithoutExtension(directory.path)}.zip";

    await file.rename(joinAll([directory.path, filename]));
  }
}
