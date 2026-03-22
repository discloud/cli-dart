import "dart:async";
import "dart:io";

import "package:args/command_runner.dart";
import "package:cli_spin/cli_spin.dart";
import "package:discloud/extensions/command.dart";
import "package:discloud/utils/messages.dart";

class TeamBackupCommand extends Command<void> {
  TeamBackupCommand() {
    argParser.addOption("app", mandatory: true);
  }

  @override
  final name = "backup";

  @override
  final description = "Get backup of your app code from Discloud";

  @override
  final aliases = ["bkp"];

  @override
  Future<void> run() async {
    final appId = argResults!.option("app");

    final spinner = CliSpin();

    try {
      final response = await context.api.get("/team/$appId/backup");

      spinner.success(resolveResponseMessage(response));

      if (response["backups"] case final Map data) {
        stdout.write(data["url"]);
      }
    } catch (e, s) {
      spinner.fail(resolveResponseMessage(e));
      context.debug(s);
    }
  }
}
