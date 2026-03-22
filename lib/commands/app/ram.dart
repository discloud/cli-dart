import "dart:async";
import "dart:math";

import "package:args/command_runner.dart";
import "package:cli_spin/cli_spin.dart";
import "package:discloud/extensions/command.dart";
import "package:discloud/utils/messages.dart";

class AppRamCommand extends Command<void> {
  AppRamCommand() {
    argParser
      ..addOption("app", mandatory: true)
      ..addOption("amount", aliases: const ["ram"], mandatory: true);
  }

  @override
  final name = "ram";

  @override
  final description = "Set amount of ram for your app";

  @override
  Future<void> run() async {
    final appId = argResults!.option("app");
    final ramMB = max(int.parse(argResults!.option("amount")!), 100);

    final spinner = CliSpin().start();

    try {
      final response = await context.api.put(
        "/app/$appId/ram",
        body: {"ramMB": ramMB},
      );

      spinner.success(resolveResponseMessage(response));
    } catch (e, s) {
      spinner.fail(resolveResponseMessage(e));
      context.debug(s);
    }
  }
}
