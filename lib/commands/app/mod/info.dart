import "dart:async";
import "dart:io";

import "package:args/command_runner.dart";
import "package:cli_spin/cli_spin.dart";
import "package:discloud/extensions/command.dart";
import "package:discloud/utils/ascii_table.dart";
import "package:discloud/utils/messages.dart";

class AppModInfoCommand extends Command<void> {
  AppModInfoCommand() {
    argParser.addOption("app", mandatory: true);
  }

  @override
  final name = "info";

  @override
  final description = "Get MOD info of your app";

  @override
  Future<void> run() async {
    final appId = argResults!.option("app");

    final spinner = CliSpin().start();

    try {
      final response = await context.api.get("/app/$appId/team");

      spinner.success(resolveResponseMessage(response));

      if (response["app"] case final Map data) {
        stdout.writeln(mapToVerticalAsciiTable(data));
      }
    } catch (e, s) {
      spinner.fail(resolveResponseMessage(e));
      context.debug(s);
    }
  }
}
