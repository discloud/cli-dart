import "dart:async";

import "package:args/command_runner.dart";
import "package:discloud/extensions/command.dart";
import "package:discloud/utils/messages.dart";

class AppModDeleteCommand extends Command<void> {
  AppModDeleteCommand() {
    argParser
      ..addOption("app", mandatory: true)
      ..addOption("mod", mandatory: true);
  }

  @override
  final name = "delete";

  @override
  final description = "Delete MOD of your app";

  @override
  Future<void> run() async {
    final appId = argResults!.option("app");
    final modId = argResults!.option("mod");

    final spinner = context.printer.spin(text: "Deleting app MOD...");

    final response = await context.api.delete("/app/$appId/team$modId");

    spinner.success(resolveResponseMessage(response));
  }
}
