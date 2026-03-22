import "dart:async";

import "package:args/command_runner.dart";
import "package:cli_spin/cli_spin.dart";
import "package:discloud/extensions/command.dart";
import "package:discloud/services/discloud/constants.dart";
import "package:discloud/utils/messages.dart";

class AppAptUninstallCommand extends Command<void> {
  AppAptUninstallCommand() {
    argParser
      ..addOption("app", mandatory: true)
      ..addMultiOption("apt", valueHelp: appApts.join(","));
  }

  @override
  final name = "uninstall";

  @override
  final description = "Uninstall APT from your app";

  @override
  Future<void> run() async {
    final appId = argResults!.option("app");
    final apts = argResults!.multiOption("apt");

    if (apts.isEmpty) usageException("Apt option cannot be empty");

    final spinner = CliSpin().start();

    try {
      final response = await context.api.delete(
        "/app/$appId/apt",
        body: {"apt": apts.join(",")},
      );

      spinner.success(resolveResponseMessage(response));
    } catch (e, s) {
      spinner.fail(resolveResponseMessage(e));
      context.debug(s);
    }
  }
}
