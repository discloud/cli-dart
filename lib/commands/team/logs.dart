import "dart:async";
import "dart:io";

import "package:ansi_strip/ansi_strip.dart";
import "package:args/command_runner.dart";
import "package:discloud/cli/spin/ispin.dart";
import "package:discloud/extensions/command.dart";
import "package:discloud/utils/messages.dart";
import "package:path/path.dart" hide context;

const _defaultLogsDir = "discloud/logs";

final class TeamLogsCommand extends Command<void> {
  TeamLogsCommand() {
    argParser
      ..addOption(
        "app",
        valueHelp: "all",
        help:
            "When set to 'all', this command will automatically download logs and will not display URLs. If the 'out' option is not set, downloads will be made to the current folder.",
      )
      ..addOption(
        "out",
        aliases: const ["path"],
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
    final appId = argResults!.optionOrRest("app") ?? "all";
    final out = argResults!.optionOrRest("out", ["app"]);

    final spinner = context.printer.spin();

    final response = await context.api.get("/team/$appId/logs");

    spinner.success(resolveResponseMessage(response));

    switch (response["apps"]) {
      case final Map data:
        await _handleSingle(data, out, spinner);
        break;
      case final List list:
        await _handleMulti(list, out: out ?? _defaultLogsDir, spinner: spinner);
        break;
    }
  }

  Future<void> _handleSingle(
    Map<dynamic, dynamic> data,
    String? out,
    ISpin spinner,
  ) async {
    if (data["terminal"]?["big"] case final String contents) {
      if (out case final out?) {
        final appId = data["id"]?.toString() ?? "app";
        return _saveLog(contents, _resolveLogPath(out, appId), spinner);
      }
      context.printer.writeln(contents);
    }
  }

  Future<void> _handleMulti(
    List list, {
    required String out,
    required ISpin spinner,
  }) async {
    for (final data in list) {
      await _handleSingle(data, out, spinner);
    }
  }

  Future<void> _saveLog(String data, String out, ISpin spinner) async {
    final file = File(out);
    await file.parent.create(recursive: true);
    await file.writeAsString(stripAnsi(data));
    spinner.success(out);
  }

  String _resolveLogPath(String out, String appId) {
    if (extension(out).isNotEmpty) return out;

    return joinAll([out, "$appId.log"]);
  }
}
