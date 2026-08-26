import "dart:async";

import "package:args/command_runner.dart";
import "package:discloud/extensions/command.dart";
import "package:discloud/utils/messages.dart";

final class AppStartCommand extends Command<void> {
  new() {
    argParser.addOption("app", valueHelp: "all");
  }

  @override
  final name = "start";

  @override
  final description = "Start one or all of your apps on Discloud";

  @override
  Future<void> run() async {
    final appId = argResults!.optionOrRest("app") ?? "all";

    final spinner = context.printer.spin(text: "Starting app...");

    final response = await context.api.put("/app/$appId/start");

    spinner.success(resolveResponseMessage(response));
  }
}
