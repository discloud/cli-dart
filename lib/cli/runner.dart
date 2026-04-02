import "dart:io";

import "package:args/command_runner.dart";
import "package:discloud/commands/commands.dart";
import "package:discloud/commands/team.dart";
import "package:discloud/version.dart";

class CliCommandRunner extends CommandRunner<void> {
  CliCommandRunner()
    : super("discloud", "A fast option to manage your apps on Discloud.") {
    argParser
      ..addFlag(
        "debug",
        help: "Use this to diagnose errors or bugs.",
        negatable: false,
      )
      ..addFlag(
        "version",
        help: "Print version. (v$packageVersion)",
        negatable: false,
        callback: (value) {
          if (value) {
            stdout.writeln("v$packageVersion");
            exit(0);
          }
        },
      );

    addCommand(AppCommand());
    addCommand(InitCommand());
    addCommand(LoginCommand());
    addCommand(TeamCommand());
    addCommand(UserCommand());
    addCommand(ZipCommand());
  }
}
