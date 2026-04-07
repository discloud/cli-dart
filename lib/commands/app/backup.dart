import "dart:async";
import "dart:io";

import "package:args/command_runner.dart";
import "package:cli_spin/cli_spin.dart";
import "package:discloud/extensions/command.dart";
import "package:discloud/utils/download.dart";
import "package:discloud/utils/messages.dart";
import "package:path/path.dart" hide context;

class AppBackupCommand extends Command<void> {
  AppBackupCommand() {
    argParser
      ..addOption(
        "app",
        mandatory: true,
        valueHelp: "all",
        help:
            "When set to 'all', this command will automatically download backups and will not display URLs. If the 'out' option is not set, downloads will be made to the current folder.",
      )
      ..addOption(
        "out",
        help:
            "Specifies the destination path for downloading backups. When the application option is set to 'all', the destination path will be considered a directory where all downloads will be stored.",
      );
  }

  @override
  final name = "backup";

  @override
  final description = "Get backup of your app code from Discloud";

  @override
  final aliases = ["bkp"];

  @override
  Future<void> run() async {
    final appId = argResults!.option("app");

    final spinner = context.printer.spin();

    try {
      final response = await context.api.get("/app/$appId/backup");

      spinner.success(resolveResponseMessage(response));

      switch (response["backups"]) {
        case final Map data:
          await _handleSingle(data, spinner);
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
    CliSpin spinner,
  ) async {
    if (data["url"] case final String url) {
      if (argResults?.option("out") case final out?) {
        spinner.start(_downloadingText);
        try {
          await download(url, out: out);
          spinner
            ..success(out)
            ..start(_downloadingText);
        } catch (e, s) {
          spinner.fail(resolveResponseMessage(e));
          context.printer.debug(s);
        }
        return;
      }
      stdout.writeln(url);
      return;
    }
  }

  Future<void> _handleMulti(List list, CliSpin spinner) async {
    spinner.start(_downloadingText);

    final client = HttpClient();
    final out = argResults?.option("out") ?? ".";

    for (final data in list) {
      final String appId = data["id"];
      final String status = data["status"];

      if (status != "ok") {
        spinner
          ..fail("$appId - bad backup status")
          ..start(_downloadingText);
        return;
      }

      final appZipName = "$appId.zip";
      final appZipPath = joinAll([out, appZipName]);

      final String url = data["url"];

      try {
        await download(url, out: appZipPath, client: client);
        spinner
          ..success(out)
          ..start(_downloadingText);
      } catch (e, s) {
        spinner.fail(resolveResponseMessage(e));
        context.printer.debug(s);
        spinner.start(_downloadingText);
      }
    }

    client.close();
  }
}

const _downloadingText = "Downloading...";
