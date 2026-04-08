import "dart:io";

import "package:args/command_runner.dart";
import "package:discloud/extensions/command.dart";
import "package:discloud/extensions/file.dart";
import "package:discloud/services/discloud/constants.dart";
import "package:discloud/utils/bytes.dart";
import "package:discloud/utils/zip.dart";
import "package:path/path.dart" hide context;

class ZipCommand extends Command<void> {
  ZipCommand() {
    argParser
      ..addOption("encoding", abbr: "e", allowed: const ["buffer"], hide: true)
      ..addMultiOption("glob", abbr: "g", defaultsTo: const ["**"])
      ..addOption("out", abbr: "o", help: "Zip output")
      ..addOption(
        "level",
        abbr: "l",
        help: "Compression level",
        valueHelp: "0-9",
      )
      ..addOption("password", abbr: "p", help: "Zip password");
  }

  @override
  final name = "zip";

  @override
  final description = "Make zip";

  int? get _compressionLevel {
    if (argResults?.option("level") case final l?) return .parse(l);
    return null;
  }

  @override
  Future<void> run() async {
    final directory = context.workspaceFolder;

    final encoding = argResults?.option("encoding");
    final out = argResults?.option("out") ?? "${basename(directory.path)}.zip";
    final glob = argResults?.multiOption("glob") ?? const ["**"];
    final level = _compressionLevel;
    final password = argResults?.option("password");

    final spinner = context.printer.spin(text: "Zipping...");

    final File file = .new(out);

    await zip(
      directory: directory,
      zipfile: file,
      glob: glob,
      ignore: allBlockedFiles,
      level: level,
      password: password,
      onData: (progress) {
        spinner.text = formatZipProgress(progress, directory);
      },
    );

    spinner.success("[${Bytes(await file.length())}]: ${file.path}");

    switch (encoding) {
      case "buffer":
        await stdout.addStream(file.openRead());
        await file.safeDelete();
        return;
    }
  }
}
