import "dart:io";

import "package:args/args.dart";
import "package:discloud/cli/context.dart";
import "package:discloud/cli/runner.dart";
import "package:discloud/utils/messages.dart";
import "package:discloud/version.dart";
import "package:tint/tint.dart";

void main(Iterable<String> arguments) async {
  final context = CliContext.I..config(arguments);

  final runner = CliCommandRunner();

  bool success = false;
  try {
    final argResults = runner.parse(arguments);

    _printCliHeader(argResults);

    await runner.runCommand(argResults);

    success = true;
  } /* on FormatException */ catch (e, s) {
    context.printer
      ..error(resolveResponseMessage(e))
      ..debug(s);
  } finally {
    context.printer.debug("""\t
OS ${Platform.operatingSystemVersion}
Dart SDK v${Platform.version}
Discloud CLI v$packageVersion
""");

    await context.dispose();
    exit(success ? 0 : 1);
  }
}

void _printCliHeader(ArgResults argResults) {
  final buffer = StringBuffer()
    ..writeAll([
      "discloud",
      ?_getCommandName(argResults),
      "v$packageVersion",
    ], " ");

  stderr.writeln(buffer.toString().bold());
}

String? _getCommandName(ArgResults argResults) {
  final list = <String>[];

  ArgResults? command = argResults;
  do {
    if (command case final subcommand?) {
      if (subcommand.name case final name?) list.add(name);
      command = subcommand.command;
    }
  } while (command != null);

  if (list.isEmpty) return null;

  return list.join(" ");
}
