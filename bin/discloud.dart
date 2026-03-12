import "dart:io";

import "package:args/command_runner.dart";
import "package:discloud/commands/commands.dart";

void main(Iterable<String> arguments) async {
  final runner = CommandRunner(
    "discloud",
    "A fast option to manage your apps on Discloud.",
  )..addCommand(InitCommand());

  try {
    await runner.run(arguments);
  } /* on FormatException */ catch (e) {
    print(e);
    exit(1);
  }

  exit(0);
}
