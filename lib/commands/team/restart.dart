import "dart:async";

import "package:args/command_runner.dart";
import "package:discloud/extensions/command.dart";
import "package:discloud/utils/messages.dart";

class TeamRestartCommand extends Command<void> {
  TeamRestartCommand() {
    argParser.addOption("app", valueHelp: "all");
  }

  @override
  final name = "restart";

  @override
  final description = "Restart one or all of your apps on Discloud";

  @override
  Future<void> run() async {
    final appId = argResults!.option("app");

    final spinner = context.printer.spin(text: "Restarting app...");

    final response = await context.api.put("/team/$appId/restart");

    spinner.success(resolveResponseMessage(response));
  }
}
