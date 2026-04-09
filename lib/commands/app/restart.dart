import "dart:async";

import "package:args/command_runner.dart";
import "package:discloud/extensions/command.dart";
import "package:discloud/utils/messages.dart";

class AppRestartCommand extends Command<void> {
  AppRestartCommand() {
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

    final response = await context.api.put("/app/$appId/restart");

    spinner.success(resolveResponseMessage(response));
  }
}
