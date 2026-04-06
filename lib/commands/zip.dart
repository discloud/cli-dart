import "dart:io";

import "package:args/command_runner.dart";
import "package:cli_spin/cli_spin.dart";
import "package:discloud/extensions/command.dart";
import "package:discloud/services/discloud/constants.dart";
import "package:discloud/utils/zip.dart";
import "package:path/path.dart" hide context;

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
    final encoding = argResults?.option("encoding");
    final out = argResults?.option("out");
    final glob = argResults?.multiOption("glob") ?? const ["**"];

    final directory = context.workspaceFolder;

    final spinner = CliSpin().start("Zipping...");

    final File file;
    try {
      file = await zip(
        directory: directory,
        glob: glob,
        ignore: allBlockedFiles,
        onData: (progress) {
          spinner.text = formatZipProgress(progress, directory);
        },
      );
    } catch (e, s) {
      spinner.fail(e.toString());
      context.debug(s);
      return;
    }

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
