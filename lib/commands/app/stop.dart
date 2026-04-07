import "dart:async";

import "package:args/command_runner.dart";
import "package:discloud/extensions/command.dart";
import "package:discloud/utils/messages.dart";

class AppStopCommand extends Command<void> {
  AppStopCommand() {
    argParser.addOption("app", valueHelp: "all");
  }

  @override
  final name = "stop";

  @override
  final description = "Stop one or all of your apps on Discloud";

  @override
  Future<void> run() async {
    final appId = argResults!.option("app");

    final spinner = context.printer.spin();

    final response = await context.api.put("/app/$appId/stop");

    spinner.success(resolveResponseMessage(response));
  }
}
