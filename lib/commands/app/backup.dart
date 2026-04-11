import "dart:async";
import "dart:io";

import "package:args/command_runner.dart";
import "package:discloud/cli/spin/ispin.dart";
import "package:discloud/extensions/command.dart";
import "package:discloud/utils/download.dart";
import "package:discloud/utils/messages.dart";
import "package:discloud/utils/speed_monitor.dart";

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
        final Uri uri = .parse(url);

        return _download(dir: dir, spinner: spinner, uri: uri);
      }

      context.printer.writeln(url);
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

      await _download(dir: dir, spinner: spinner, uri: uri, client: client);
    }

    client.close();
  }

  Future<void> _download({
    required String dir,
    required ISpin spinner,
    required Uri uri,
    HttpClient? client,
  }) async {
    final filename = uri.pathSegments.last;
    final filepath = "$dir$_pSep$filename";
    final File file = .new(filepath);

    final monitor = SpeedMonitor();

    try {
      spinner.start("Downloading...");

      await download(
        uri,
        file: file,
        client: client,
        onProgress: (processed, total) {
          spinner.text = formatDownloadProgress(
            speed: monitor.add(processed),
            processed: processed,
            total: total,
          );
        },
      );

      spinner.success(filepath);
    } catch (e, s) {
      spinner.fail(resolveResponseMessage(e));
      context.printer.debug(s);
    } finally {
      monitor.dispose();
    }
  }
}
