import "dart:io";

import "package:args/command_runner.dart";
import "package:cli_spin/cli_spin.dart";
import "package:discloud/extensions/command.dart";
import "package:discloud/utils/messages.dart";

class UserLocaleCommand extends Command<void> {
  UserLocaleCommand() {
    argParser.addOption(
      "locale",
      abbr: "l",
      mandatory: true,
      valueHelp: Platform.localeName,
    );
  }

  @override
  final name = "locale";

  @override
  final description = "Set your locale";

  @override
  Future<void> run() async {
    final locale = argResults!.option("locale");

    final spinner = CliSpin().start();

    try {
      final response = await context.api.put("/locale/$locale");
      spinner.success(resolveResponseMessage(response));
    } catch (e, s) {
      spinner.fail(resolveResponseMessage(e));
      context.debug(s);
    }
  }
}
