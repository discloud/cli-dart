import "package:args/command_runner.dart";
import "package:discloud/cli/context.dart";
import "package:discloud/extensions/command.dart";
import "package:discloud/services/discloud/constants.dart";
import "package:discloud/utils/messages.dart";
import "package:interact/interact.dart";

final class UserLocaleCommand extends Command<void> {
  UserLocaleCommand() {
    argParser
      ..addOption("locale", abbr: "l", valueHelp: localeName)
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

    final locale = _resolveLocale(system);

    final spinner = context.printer.spin(
      text: "Defining the user's locale to $locale...",
    );

    final response = await context.api.put("/locale/$locale");

    spinner.success(resolveResponseMessage(response));
  }

  String _resolveLocale(bool system) {
    final locale = switch ((system, argResults!.option("locale"))) {
      (true, _) => context.locale,
      (_, final String value) => value,
      _ => apiLocales.elementAt(
        Select(
          prompt: "Choose your locale",
          options: apiLocales.toList(),
        ).interact(),
      ),
    }.replaceAll("_", "-");

    if (!apiLocales.contains(locale)) {
      usageException("Unsupported locale: $locale (${apiLocales.join(", ")})");
    }

    return locale;
  }
}
