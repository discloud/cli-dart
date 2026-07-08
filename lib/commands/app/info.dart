import "dart:async";

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

final class AppInfoCommand extends Command<void> {
  AppInfoCommand() {
    argParser.addOption("app", valueHelp: "all");
  }

  @override
  final name = "info";

  @override
  final description = "Get information of your apps";

  @override
  Future<void> run() async {
    final appId = argResults!.optionOrRest("app") ?? "all";

    final spinner = context.printer.spin(text: "Fetching app info...");

    final response = await context.api.get("/app/$appId");

    spinner.success(resolveResponseMessage(response));

    switch (response["apps"]) {
      case final List list:
        context.printer.writeln(listToAsciiTable(list, _keysIgnore));
        break;
      case final Map data:
        context.printer.writeln(mapToVerticalAsciiTable(data, _keysIgnore));
        break;
    }
  }
}
