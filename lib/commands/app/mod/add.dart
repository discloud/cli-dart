import "dart:async";

import "package:args/command_runner.dart";
import "package:discloud/extensions/command.dart";
import "package:discloud/services/discloud/constants.dart";
import "package:discloud/utils/messages.dart";

class AppModAddCommand extends Command<void> {
  AppModAddCommand() {
    argParser
      ..addOption("app", mandatory: true)
      ..addOption("mod", mandatory: true)
      ..addMultiOption("perms", allowed: appModPerms);
  }

  @override
  final name = "add";

  @override
  final description = "Add MOD to your app";

  @override
  Future<void> run() async {
    final appId = argResults!.option("app");
    final modId = argResults!.option("mod");
    final perms = argResults!.multiOption("perms");

    final spinner = context.printer.spin();

    try {
      final response = await context.api.post(
        "/app/$appId/team",
        body: {"modID": modId, "perms": perms},
      );

      spinner.success(resolveResponseMessage(response));
    } catch (e, s) {
      spinner.fail(resolveResponseMessage(e));
      context.printer.debug(s);
    }
  }
}
