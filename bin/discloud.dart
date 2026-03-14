import "dart:io";

import "package:args/command_runner.dart";
import "package:discloud/commands/commands.dart";

void main(Iterable<String> arguments) async {
  final runner =
      CommandRunner<void>(
          "discloud",
          "A fast option to manage your apps on Discloud.",
        )
        ..addCommand(InitCommand())
        ..addCommand(LoginCommand())
        ..addCommand(ZipCommand());

  try {
    await runner.run(arguments);
  } /* on FormatException */ catch (e) {
    stderr.write(e);
    exit(1);
  }

  exit(0);
}
