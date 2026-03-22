import "dart:async";

import "package:args/command_runner.dart";
import "package:cli_spin/cli_spin.dart";
import "package:discloud/extensions/command.dart";
import "package:discloud/utils/messages.dart";

class TeamRestartCommand extends Command<void> {
  TeamRestartCommand() {
    argParser.addOption("app", defaultsTo: "all");
  }

  @override
  final name = "restart";

  @override
  final description = "Restart one or all of your apps on Discloud";

  @override
  Future<void> run() async {
    final appId = argResults!.option("app");

    final spinner = CliSpin().start();

    try {
      final response = await context.api.put("/team/$appId/restart");

      spinner.success(resolveResponseMessage(response));
    } catch (e, s) {
      spinner.fail(resolveResponseMessage(e));
      context.debug(s);
    }
  }
}
