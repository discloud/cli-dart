import "dart:async";
import "dart:io";

import "package:args/command_runner.dart";
import "package:discloud/extensions/command.dart";
import "package:intl/intl.dart";

final class SystemLocaleCommand extends Command<void> {
  SystemLocaleCommand();

  @override
  final name = "locale";

  @override
  final description = "Get locale info";

  @override
  Future<void> run() async {
    final StringBuffer sb = .new()
      ..writeAll([
        "Platform locale: ${Platform.localeName}",
        "Current locale: ${Intl.getCurrentLocale()}",
        "Default locale: ${Intl.defaultLocale}",
        "System locale: ${Intl.systemLocale}",
        "Canonicalized locale: ${Intl.canonicalizedLocale(Platform.localeName)}",
        "Short locale: ${Intl.shortLocale(Platform.localeName)}",
      ], "\n");

    context.printer.info(sb);
  }
}
