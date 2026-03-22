import "dart:async";

import "package:args/command_runner.dart";
import "package:cli_spin/cli_spin.dart";
import "package:discloud/extensions/command.dart";
import "package:discloud/utils/messages.dart";
import "package:interact/interact.dart";

class AppDeleteCommand extends Command<void> {
  AppDeleteCommand() {
    argParser
      ..addFlag("yes", abbr: "y", help: "Skip confirmation prompt")
      ..addOption("app", mandatory: true);
  }

  @override
  final name = "delete";

  @override
  final description = "Delete one of your apps on Discloud";

  @override
  Future<void> run() async {
    final appId = argResults!.option("app");

    final result =
        argResults!.flag("yes") ||
        Confirm(
          prompt:
              "You are DELETING $appId. This action is irreversible! Are sure about it?",
        ).interact();

    if (!result) return;

    final spinner = CliSpin().start();

    try {
      final response = await context.api.delete("/app/$appId/delete");

      spinner.success(resolveResponseMessage(response));
    } catch (e, s) {
      spinner.fail(resolveResponseMessage(e));
      context.debug(s);
    }
  }
}
