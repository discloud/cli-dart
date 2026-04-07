import "dart:async";
import "dart:io";

import "package:args/command_runner.dart";
import "package:cli_spin/cli_spin.dart";
import "package:discloud/extensions/command.dart";
import "package:discloud/utils/download.dart";
import "package:discloud/utils/messages.dart";
import "package:discloud/utils/percent.dart";
import "package:path/path.dart" hide context;

class TeamBackupCommand extends Command<void> {
  TeamBackupCommand() {
    argParser.addOption("app", mandatory: true, valueHelp: "all");
  }

  @override
  final name = "backup";

  @override
  final description = "Get backup of your team app code from Discloud";

  @override
  final aliases = ["bkp"];

  @override
  Future<void> run() async {
    final appId = argResults!.option("app");

    final spinner = context.printer.spin();

    final response = await context.api.get("/team/$appId/backup");

    spinner.success(resolveResponseMessage(response));

    switch (response["backups"]) {
      case final Map data:
        await _handleSingle(data, spinner);
        break;
      case final List list:
        await _handleMulti(list, spinner);
        break;
    }
  }

  Future<void> _handleSingle(
    Map<dynamic, dynamic> data,
    CliSpin spinner,
  ) async {
    if (data["url"] case final String url) {
      if (argResults?.option("out") case final out?) {
        spinner.start(_downloadingText);

        await download(
          url,
          out: out,
          onProgress: (processed, total) {
            spinner.text = "$_downloadingText ${percent(processed, total)}%";
          },
        );

        spinner.success(out);
        return;
      }
      context.printer.writeln(url);
      return;
    }
  }

  Future<void> _handleMulti(List list, CliSpin spinner) async {
    final client = HttpClient();
    final out = argResults?.option("out") ?? ".";

    for (final data in list) {
      final String appId = data["id"];
      final String status = data["status"];

      if (status != "ok") {
        spinner.fail("$appId - bad backup status");
        continue;
      }

      final appZipName = "$appId.zip";
      final appZipPath = joinAll([out, appZipName]);

      final String url = data["url"];

      try {
        spinner.start(_downloadingText);

        await download(
          url,
          out: appZipPath,
          client: client,
          onProgress: (processed, total) {
            spinner.text = "$_downloadingText ${percent(processed, total)}%";
          },
        );

        spinner.success(appZipPath);
      } catch (e, s) {
        spinner.fail(resolveResponseMessage(e));
        context.printer.debug(s);
      }
    }

    client.close();
  }
}

const _downloadingText = "Downloading...";
