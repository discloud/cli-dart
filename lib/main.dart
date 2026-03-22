import "dart:io";

import "package:args/args.dart";
import "package:args/command_runner.dart";
import "package:discloud/cli/context.dart";
import "package:discloud/commands/commands.dart";
import "package:discloud/commands/team.dart";
import "package:discloud/version.dart";
import "package:tint/tint.dart";

void main(Iterable<String> arguments) async {
  final context = CliContext.I..config(arguments);

  final runner =
      CommandRunner<void>(
          "discloud",
          "A fast option to manage your apps on Discloud.",
        )
        ..argParser.addFlag(
          "debug",
          help: "Use this to diagnose errors or bugs.",
          negatable: false,
        )
        ..argParser.addFlag(
          "version",
          help: "Print version. (v$packageVersion)",
          negatable: false,
          callback: (value) {
            if (value) {
              stdout.write("v$packageVersion");
              exit(0);
            }
          },
        )
        ..addCommand(AppCommand())
        ..addCommand(InitCommand())
        ..addCommand(LoginCommand())
        ..addCommand(TeamCommand())
        ..addCommand(UserCommand())
        ..addCommand(ZipCommand());

  bool success = false;
  try {
    final argResults = runner.parse(arguments);

    _printCliHeader(argResults);

    await runner.runCommand(argResults);
    success = true;
  } /* on FormatException */ catch (e, s) {
    stderr.writeln(e);
    context.debug(s);
  } finally {
    await context.dispose();
    exit(success ? 0 : 1);
  }
}

void _printCliHeader(ArgResults argResults) {
  final list = ["discloud"];

  ArgResults? command = argResults;
  do {
    if (command case final subcommand?) {
      if (subcommand.name case final name?) list.add(name);
      command = subcommand.command;
    }
  } while (command != null);

  list.add("v$packageVersion");

  stderr.writeln(list.join(" ").bold());
}
