import "dart:async";

import "package:args/command_runner.dart";
import "package:discloud/extensions/command.dart";
import "package:discloud/services/discloud/constants.dart";
import "package:discloud/utils/messages.dart";

class AppAptInstallCommand extends Command<void> {
  AppAptInstallCommand() {
    argParser
      ..addOption("app", mandatory: true)
      ..addMultiOption("apt", help: appApts.join(","));
  }

  @override
  final name = "install";

  @override
  final description = "Install APT on your app";

  @override
  Future<void> run() async {
    final appId = argResults!.option("app");
    final apts = argResults!.multiOption("apt");

    if (apts.isEmpty) usageException("Apt option cannot be empty");

    final spinner = context.printer.spin();

    try {
      final response = await context.api.put(
        "/app/$appId/apt",
        body: {"apt": apts.join(",")},
      );

      spinner.success(resolveResponseMessage(response));
    } catch (e, s) {
      spinner.fail(resolveResponseMessage(e));
      context.printer.debug(s);
    }
  }
}
