import "dart:io";

import "package:args/command_runner.dart";
import "package:discloud/extensions/command.dart";
import "package:discloud/utils/messages.dart";

class UserLocaleCommand extends Command<void> {
  static const _localePattern = r"^\w{2}[-_]\w{2}$";
  static final _localeRegexp = RegExp(_localePattern);
  static final _localeName =
      _localeRegexp.firstMatch(Platform.localeName)?.input ?? "en-US";

  UserLocaleCommand() {
    argParser.addOption(
      "locale",
      abbr: "l",
      mandatory: true,
      valueHelp: _localeName,
    );
  }

  @override
  final name = "locale";

  @override
  final description = "Set your locale";

  @override
  Future<void> run() async {
    final locale = argResults!.option("locale");

    final spinner = context.printer.spin();

    try {
      final response = await context.api.put("/locale/$locale");
      spinner.success(resolveResponseMessage(response));
    } catch (e, s) {
      spinner.fail(resolveResponseMessage(e));
      context.printer.debug(s);
    }
  }
}
