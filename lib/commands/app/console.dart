import "dart:async";
import "dart:io";

import "package:args/command_runner.dart";
import "package:discloud/cli/spin/ispin.dart";
import "package:discloud/extensions/command.dart";
import "package:discloud/services/discloud/exception.dart";
import "package:discloud/utils/messages.dart";

const _commandPrefix = "\x1B[2m?> \x1B[22m";
const _exitCommand = "exit";

final class AppConsoleCommand extends Command<void> {
  new() {
    argParser
      ..addOption("app")
      ..addMultiOption("command", abbr: "c");
  }

  @override
  final name = "console";

  @override
  final description = "Use the app terminal";

  @override
  final aliases = const ["terminal"];

  @override
  Future<void> run() async {
    final appId = argResults!.requiredOptionOrRest("app");

    final spinner = context.printer.spin(start: false);

    if (argResults!.multiOptionOrRest("command", const ["app"])?.join(" ")
        case final command?) {
      await _send(appId, command, spinner);
      return;
    }

    context.printer("Enter 'exit' to stop.");

    await Future.doWhile(() {
      context.printer.write(_commandPrefix);

      if (stdin.readLineSync() case final command?
          when command.isNotEmpty && command != _exitCommand) {
        return _send(appId, command, spinner);
      }

      return false;
    });
  }

  Future<bool> _send(String appId, String command, ISpin spinner) async {
    spinner.start("Sending command...");

    try {
      final response = await context.api.put(
        "/app/$appId/console",
        body: {"command": command},
      );

      if (response["apps"]?["shell"] case final Map shell) {
        spinner.stop();

        if (shell["stdout"] case final String content when content.isNotEmpty) {
          stdout.writeln(content);
        }

        if (shell["stderr"] case final String content when content.isNotEmpty) {
          stderr.writeln(content);
        }

        return true;
      }

      spinner.fail(resolveResponseMessage(response));

      return true;
    } on DiscloudApiException catch (e, s) {
      final text = switch (e.code) {
        401 => "[Error ${e.code}]: Invalid Discloud token",
        404 => "[Error ${e.code}]: App not found on Discloud",
        429 => "[Error ${e.code}]: Rate limited",
        _ => "[Error ${e.code}]: ${e.message}",
      };

      spinner.fail(text);
      context.printer.debug(s);
      return false;
    }
  }
}
