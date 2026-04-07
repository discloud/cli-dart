import "dart:async";
import "dart:io";

import "package:ansi_strip/ansi_strip.dart";
import "package:args/command_runner.dart";
import "package:cli_spin/cli_spin.dart";
import "package:discloud/extensions/command.dart";
import "package:discloud/utils/messages.dart";
import "package:path/path.dart" hide context;

class AppLogsCommand extends Command<void> {
  AppLogsCommand() {
    argParser
      ..addOption(
        "app",
        mandatory: true,
        valueHelp: "all",
        help:
            "When set to 'all', this command will automatically download logs and will not display URLs. If the 'out' option is not set, downloads will be made to the current folder.",
      )
      ..addOption(
        "out",
        help:
            "Specifies the destination path for downloading logs. When the application option is set to 'all', the destination path will be considered a directory where all downloads will be stored.",
      );
  }

  @override
  final name = "logs";

  @override
  final description = "View the logs from application in Discloud";

  @override
  Future<void> run() async {
    final appId = argResults!.option("app");

    final spinner = context.printer.spin();

    try {
      final response = await context.api.get("/app/$appId/logs");

      spinner.success(resolveResponseMessage(response));

      switch (response["apps"]) {
        case final Map data:
          await _handleSingle(data, argResults?.option("out"), spinner);
          break;
        case final List list:
          await _handleMulti(list, spinner);
          break;
      }

      spinner.stop();
    } catch (e, s) {
      spinner.fail(resolveResponseMessage(e));
      context.printer.debug(s);
    }
  }

  Future<void> _handleSingle(
    Map<dynamic, dynamic> data,
    String? out,
    CliSpin spinner,
  ) async {
    if (data["terminal"]?["big"] case final String data) {
      if (out case final out?) {
        await _saveLog(data, out, spinner);
        return;
      }
      stdout.writeln(data);
      return;
    }
  }

  Future<void> _handleMulti(List list, CliSpin spinner) async {
    final out = argResults?.option("out") ?? ".";

    for (final data in list) {
      final String appId = data["id"];
      final filename = "$appId.log";
      final filepath = joinAll([out, filename]);
      await _handleSingle(data, filepath, spinner);
    }
  }

  Future<void> _saveLog(String data, String out, CliSpin spinner) async {
    final file = File(out);
    await file.create(recursive: true);
    await file.writeAsString(stripAnsi(data));
    spinner.success(out);
  }
}
