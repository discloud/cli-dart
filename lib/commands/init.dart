import "dart:async";
import "dart:io";

import "package:args/command_runner.dart";
import "package:discloud/extensions/string.dart";
import "package:discloud_config/discloud_config.dart";

class InitCommand extends Command<void> {
  InitCommand() {
    argParser
      ..addFlag("force", abbr: "f", negatable: false)
      ..addOption("main")
      ..addOption("type", allowed: const ["bot", "site"]);
  }

  @override
  final name = "init";

  @override
  final description = "Init ${DiscloudConfig.filename} file";

  @override
  Future<void> run() async {
    final file = File(DiscloudConfig.filename);

    if (!argResults!.flag("force") && await file.exists()) {
      throw Exception("${DiscloudConfig.filename} already exists!");
    }

    final sink = file.openWrite()
      ..writeAll([
        "# https://docs.discloud.com/en/discloud.config",
        "MAIN=${argResults?.option("main").orEmpty}",
        if (argResults?.option("type") case final type?) "TYPE=$type",
      ], "\n");

    await sink.close();
  }
}
