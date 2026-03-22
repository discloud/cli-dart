import "dart:async";

import "package:args/command_runner.dart";
import "package:cli_spin/cli_spin.dart";
import "package:discloud/extensions/command.dart";
import "package:discloud/services/discloud/constants.dart";
import "package:discloud/utils/messages.dart";

class AppModEditCommand extends Command<void> {
  AppModEditCommand() {
    argParser
      ..addOption("app", mandatory: true)
      ..addOption("mod", mandatory: true)
      ..addMultiOption("perms", allowed: appModPerms);
  }

  @override
  final name = "edit";

  @override
  final description = "Edit MOD perms of your app";

  @override
  Future<void> run() async {
    final appId = argResults!.option("app");
    final modId = argResults!.option("mod");
    final perms = argResults!.multiOption("perms");

    final spinner = CliSpin().start();

    try {
      final response = await context.api.put(
        "/app/$appId/team",
        body: {"modID": modId, "perms": perms},
      );

      spinner.success(resolveResponseMessage(response));
    } catch (e, s) {
      spinner.fail(resolveResponseMessage(e));
      context.debug(s);
    }
  }
}
