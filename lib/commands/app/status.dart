import "dart:async";
import "dart:io";

import "package:args/command_runner.dart";
import "package:cli_spin/cli_spin.dart";
import "package:discloud/extensions/command.dart";
import "package:discloud/utils/ascii_table.dart";
import "package:discloud/utils/messages.dart";

const _keysToIgnore = {"netIO"};

class AppStatusCommand extends Command<void> {
  AppStatusCommand() {
    argParser.addOption("app", mandatory: true);
  }

  @override
  final name = "status";

  @override
  final description = "Get status of your app";

  @override
  Future<void> run() async {
    final appId = argResults!.option("app");

    final spinner = CliSpin().start();

    try {
      final response = await context.api.get("/app/$appId/status");

      spinner.success(resolveResponseMessage(response));

      if (response["apps"] case final data?) {
        stdout.writeln(mapToVerticalAsciiTable(data, _keysToIgnore));
      }
    } catch (e, s) {
      spinner.fail(resolveResponseMessage(e));
      context.debug(s);
    }
  }
}
