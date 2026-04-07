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

class TeamInfoCommand extends Command<void> {
  TeamInfoCommand() {
    argParser.addOption("app");
  }

  @override
  final name = "info";

  @override
  final description = "Get information of your apps";

  @override
  Future<void> run() async {
    final appId = argResults!.option("app");

    final spinner = context.printer.spin();

    final route = appId == null ? "/team" : "/team/$appId";

    final response = await context.api.get(route);

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
