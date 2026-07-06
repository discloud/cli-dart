import "package:args/command_runner.dart";
import "package:discloud/cli/context.dart";
import "package:discloud/extensions/command.dart";
import "package:discloud/utils/messages.dart";

final class UserLocaleCommand extends Command<void> {
  UserLocaleCommand() {
    argParser
      ..addOption("locale", abbr: "l", mandatory: true, valueHelp: localeName)
      ..addFlag(
        "system",
        abbr: "s",
        help: "Use current system language ($localeName)",
        negatable: false,
      );
  }

  @override
  final name = "locale";

  @override
  final description = "Set your locale";

  @override
  Future<void> run() async {
    final system = argResults!.flag("system");

    final locale = system ? context.locale : argResults!.option("locale");

    final spinner = context.printer.spin(
      text: "Defining the user's locale to $locale...",
    );

    final response = await context.api.put("/locale/$locale");

    spinner.success(resolveResponseMessage(response));
  }
}
