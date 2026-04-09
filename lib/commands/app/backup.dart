import "dart:async";
import "dart:io";

import "package:args/command_runner.dart";
import "package:discloud/cli/spin/ispin.dart";
import "package:discloud/extensions/command.dart";
import "package:discloud/utils/download.dart";
import "package:discloud/utils/messages.dart";
import "package:discloud/utils/percent.dart";

const _pSep = "/";

class AppBackupCommand extends Command<void> {
  AppBackupCommand() {
    argParser
      ..addOption("app", mandatory: true, valueHelp: "all")
      ..addOption(
        "dir",
        abbr: "d",
        aliases: const ["out"],
        help:
            "Specifies the destination path for downloading backups. The destination path will be considered a directory.",
      );
  }

  @override
  final name = "backup";

  @override
  final description = "Get backup of your app code from Discloud";

  @override
  final aliases = const ["bkp"];

  @override
  Future<void> run() async {
    final appId = argResults!.option("app");

    final spinner = context.printer.spin(text: "Fetching backup...");

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
  }

  Future<void> _handleSingle(Map<dynamic, dynamic> data, ISpin spinner) async {
    if (data["url"] case final String url) {
      if (argResults?.option("dir") case final dir?) {
        spinner.start(_downloadingText);

        final Uri uri = .parse(url);
        final filename = uri.pathSegments.last;
        final appZipPath = "$dir$_pSep$filename";

        await download(
          uri.toString(),
          out: appZipPath,
          onProgress: (processed, total) {
            spinner.text = "$_downloadingText ${percent(processed, total)}%";
          },
        );

        spinner.success(appZipPath);
        return;
      }
      context.printer.writeln(url);
      return;
    }
  }

  Future<void> _handleMulti(List list, ISpin spinner) async {
    final client = HttpClient();
    final dir = argResults?.option("dir") ?? ".";

    for (final data in list) {
      final String appId = data["id"];
      final String status = data["status"];

      if (status != "ok") {
        spinner.fail("$appId - bad backup status");
        continue;
      }

      final String url = data["url"];

      final Uri uri = .parse(url);
      final filename = uri.pathSegments.last;
      final appZipPath = "$dir$_pSep$filename";

      try {
        spinner.start(_downloadingText);

        await download(
          uri.toString(),
          out: appZipPath,
          client: client,
          onProgress: (processed, total) {
            spinner.text =
                "Downloading backup of $appId: ${percent(processed, total)}%";
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
