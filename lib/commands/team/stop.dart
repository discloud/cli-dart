import "dart:async";

import "package:args/command_runner.dart";
import "package:cli_spin/cli_spin.dart";
import "package:discloud/extensions/command.dart";
import "package:discloud/utils/messages.dart";

class TeamStopCommand extends Command<void> {
  TeamStopCommand() {
    argParser.addOption("app", defaultsTo: "all");
  }

  @override
  final name = "stop";

  @override
  final description = "Stop one or all of your apps on Discloud";

  @override
  Future<void> run() async {
    final appId = argResults!.option("app");

    final spinner = CliSpin().start();

    try {
      final response = await context.api.put("/team/$appId/stop");

      spinner.success(resolveResponseMessage(response));
    } catch (e, s) {
      spinner.fail(resolveResponseMessage(e));
      context.debug(s);
    }
  }
}
