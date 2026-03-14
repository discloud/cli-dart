import "dart:async";
import "dart:io";

import "package:args/command_runner.dart";
import "package:discloud/constants.dart";

class InitCommand extends Command<void> {
  InitCommand() {
    argParser
      ..addFlag("force", abbr: "f", negatable: false)
      ..addFlag("yes", abbr: "y", negatable: false)
      ..addOption("main")
      ..addOption("type", allowed: ["bot", "site"]);
  }

  @override
  final name = "init";

  @override
  final description = "Init $configFilename file";

  @override
  Future<void> run() async {
    final file = File(configFilename);

    if (!argResults!.flag("force") && await file.exists()) {
      throw Exception("$configFilename already exists!");
    }

    final sink = file.openWrite()
      ..writeAll([
        "# https://docs.discloud.com/en/discloud.config",
        "MAIN=${argResults?.option("main") ?? ""}",
      ], "\n");

    await sink.close();
  }
}
