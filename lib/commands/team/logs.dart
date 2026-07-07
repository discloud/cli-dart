import "dart:async";
import "dart:io";

import "package:ansi_strip/ansi_strip.dart";
import "package:args/command_runner.dart";
import "package:discloud/cli/spin/ispin.dart";
import "package:discloud/extensions/command.dart";
import "package:discloud/utils/messages.dart";
import "package:path/path.dart" hide context;

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
    final out = argResults!.optionOrRest("out", const ["app"]);

    final spinner = context.printer.spin();

    final response = await context.api.get("/team/$appId/logs");

    spinner.success(resolveResponseMessage(response));

    switch (response["apps"]) {
      case final Map data:
        await _handleSingle(data, spinner, appId, out);
        break;
      case final List list:
        await _handleMulti(list, spinner, out ?? ".");
        break;
    }
  }

  Future<void> _handleSingle(
    Map<dynamic, dynamic> data,
    ISpin spinner,
    String appId,
    String? out,
  ) async {
    if (data["terminal"]?["big"] case final String contents) {
      if (out case final out?) {
        return _saveLog(contents, _resolvePath(out, appId), spinner);
      }
      context.printer.writeln(contents);
    }
  }

  Future<void> _handleMulti(List list, ISpin spinner, String out) async {
    for (final data in list) {
      final String appId = data["id"];
      await _handleSingle(data, spinner, appId, out);
    }
  }

  Future<void> _saveLog(String data, String out, ISpin spinner) async {
    final File file = .new(out);
    await file.parent.create(recursive: true);
    await file.writeAsString(stripAnsi(data));
    spinner.success(out);
  }

  String _resolvePath(String out, String appId) {
    if (extension(out).isNotEmpty) return out;
    return joinAll([out, "$appId.log"]);
  }
}
