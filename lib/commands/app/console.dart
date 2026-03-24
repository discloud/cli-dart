import "dart:async";
import "dart:io";

import "package:args/command_runner.dart";
import "package:cli_spin/cli_spin.dart";
import "package:discloud/extensions/command.dart";
import "package:discloud/services/discloud/exception.dart";
import "package:discloud/utils/messages.dart";
import "package:tint/tint.dart";

class AppConsoleCommand extends Command<void> {
  AppConsoleCommand() {
    argParser
      ..addOption("app", mandatory: true)
      ..addOption("command");
  }

  @override
  final name = "console";

  @override
  final description = "Use the app terminal";

  @override
  final aliases = ["terminal"];

  @override
  Future<void> run() async {
    final appId = argResults!.option("app")!;
    final command = argResults!.option("command");

    final spinner = CliSpin();

    if (command case final command?) {
      await _send(appId: appId, command: command, spinner: spinner);
      return;
    }

    stdout.writeln("Enter 'exit' to stop.");

    while (true) {
      stderr.write("?> ".dim());

      final command = stdin.readLineSync();
      if (command == null || command == "exit") break;
      if (command.isEmpty) continue;

      if (!await _send(appId: appId, command: command, spinner: spinner)) break;
    }
  }

  Future<bool> _send({
    required String appId,
    required String command,
    required CliSpin spinner,
  }) async {
    spinner.start();

    try {
      final response = await context.api.put(
        "/app/$appId/console",
        body: {"command": command},
      );

      spinner.stop();

      if (response["status"] == "ok") {
        if (response["apps"]?["shell"] case final Map shell) {
          if (shell["stdout"] case final String content
              when content.isNotEmpty) {
            stdout.writeln(content);
          }

          if (shell["stderr"] case final String content
              when content.isNotEmpty) {
            stderr.writeln(content);
          }
        }
      } else {
        stderr.writeln(resolveResponseMessage(response));
      }
      return true;
    } on DiscloudApiException catch (e, s) {
      final text = switch (e.code) {
        401 => "[Error ${e.code}]: Invalid Discloud token",
        404 => "[Error ${e.code}]: App not found on Discloud",
        429 => "[Error ${e.code}]: Rate limited",
        _ => "[Error ${e.code}]: ${e.message}",
      };

      spinner.fail(text);
      context.debug(s);
      return false;
    } catch (e, s) {
      spinner.fail(e.toString());
      context.debug(s);
      return false;
    }
  }
}
