import "dart:async";
import "dart:io";

import "package:args/command_runner.dart";
import "package:discloud/extensions/command.dart";
import "package:discloud/utils/ascii_table.dart";
import "package:discloud/utils/messages.dart";

const _keysIgnore = {
  "addedAtTimestamp",
  "apts",
  "autoDeployGit",
  "autoRestart",
  "avatarURL",
  "mainFile",
  "mods",
  "ramKilled",
  "ram",
  "syncGit",
  "type",
};

class TeamInfoCommand extends Command<void> {
  TeamInfoCommand() {
    argParser.addOption("app", defaultsTo: "all");
  }

  @override
  final name = "info";

  @override
  final description = "Get information of your apps";

  @override
  Future<void> run() async {
    final appId = argResults!.option("app");

    final spinner = context.printer.spin();

    try {
      final response = await context.api.get("/team/$appId");

      spinner.success(resolveResponseMessage(response));

      switch (response["apps"]) {
        case final List list:
          stdout.writeln(listToAsciiTable(list, _keysIgnore));
          break;
        case final Map data:
          stdout.writeln(mapToVerticalAsciiTable(data, _keysIgnore));
          break;
      }
    } catch (e, s) {
      spinner.fail(resolveResponseMessage(e));
      context.printer.debug(s);
    }
  }
}
