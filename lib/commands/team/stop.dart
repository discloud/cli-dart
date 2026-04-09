import "dart:async";

import "package:args/command_runner.dart";
import "package:discloud/extensions/command.dart";
import "package:discloud/utils/messages.dart";

class TeamStopCommand extends Command<void> {
  TeamStopCommand() {
    argParser.addOption("app", valueHelp: "all");
  }

  @override
  final name = "stop";

  @override
  final description = "Stop one or all of your apps on Discloud";

  @override
  Future<void> run() async {
    final appId = argResults!.option("app");

    final spinner = context.printer.spin(text: "Stopping app...");

    final response = await context.api.put("/team/$appId/stop");

    spinner.success(resolveResponseMessage(response));
  }
}
