import "dart:async";

import "package:args/command_runner.dart";
import "package:discloud/extensions/command.dart";
import "package:discloud/utils/messages.dart";

final class AppModDeleteCommand extends Command<void> {
  AppModDeleteCommand() {
    argParser
      ..addOption("app")
      ..addOption("mod");
  }

  @override
  final name = "delete";

  @override
  final description = "Delete MOD of your app";

  @override
  Future<void> run() async {
    final appId = argResults!.requiredOptionOrRest("app");
    final modId = argResults!.requiredOptionOrRest("mod", const ["app"]);

    final spinner = context.printer.spin(text: "Deleting app MOD...");

    final response = await context.api.delete("/app/$appId/team/$modId");

    spinner.success(resolveResponseMessage(response));
  }
}
