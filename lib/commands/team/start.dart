import "dart:async";

import "package:args/command_runner.dart";
import "package:cli_spin/cli_spin.dart";
import "package:discloud/extensions/command.dart";
import "package:discloud/utils/messages.dart";

class TeamStartCommand extends Command<void> {
  TeamStartCommand() {
    argParser.addOption("app", valueHelp: "all");
  }

  @override
  final name = "start";

  @override
  final description = "Start one or all of your apps on Discloud";

  @override
  Future<void> run() async {
    final appId = argResults!.option("app");

    final spinner = CliSpin().start();

    try {
      final response = await context.api.put("/team/$appId/start");

      spinner.success(resolveResponseMessage(response));
    } catch (e, s) {
      spinner.fail(resolveResponseMessage(e));
      context.debug(s);
    }
  }
}
