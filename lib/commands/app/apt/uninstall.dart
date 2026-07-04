import "dart:async";

import "package:args/command_runner.dart";
import "package:discloud/extensions/command.dart";
import "package:discloud/services/discloud/constants.dart";
import "package:discloud/utils/messages.dart";

final class AppAptUninstallCommand extends Command<void> {
  AppAptUninstallCommand() {
    argParser
      ..addOption("app")
      ..addMultiOption("apt", allowed: appApts, help: appApts.join(","));
  }

  @override
  final name = "uninstall";

  @override
  final aliases = const ["u"];

  @override
  final description = "Uninstall APT from your app";

  @override
  Future<void> run() async {
    final appId = requiredOptionOrRest("app", 0);
    final apts = multiOptionOrRest("apt", 1);

    if (apts.isEmpty) usageException("Apt option cannot be empty");
    _validateApts(apts);

    final spinner = context.printer.spin(text: "Uninstalling app apt...");

    final response = await context.api.delete(
      "/app/$appId/apt",
      body: {"apt": apts.join(",")},
    );

    spinner.success(resolveResponseMessage(response));
  }

  void _validateApts(List<String> apts) {
    final invalid = apts.where((apt) => !appApts.contains(apt)).toList();
    if (invalid.isEmpty) return;

    usageException("Invalid APT: ${invalid.join(", ")}");
  }
}
