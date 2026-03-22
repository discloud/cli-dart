import "dart:async";
import "dart:io";

import "package:args/command_runner.dart";
import "package:cli_spin/cli_spin.dart";
import "package:discloud/extensions/command.dart";
import "package:discloud/utils/messages.dart";

class AppBackupCommand extends Command<void> {
  AppBackupCommand() {
    argParser.addOption("app", mandatory: true, valueHelp: "appId");
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
      final response = await context.api.get("/app/$appId/backup");

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
