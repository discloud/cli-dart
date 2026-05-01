import "dart:async";
import "dart:io";

import "package:args/command_runner.dart";
import "package:discloud/cli/disposable.dart";
import "package:discloud/cli/spin/ispin.dart";
import "package:discloud/extensions/command.dart";
import "package:discloud/extensions/file.dart";
import "package:discloud/utils/download.dart";
import "package:discloud/utils/messages.dart";
import "package:discloud/utils/progress.dart";
import "package:discloud/utils/speed_monitor.dart";

const _pSep = "/";

class TeamBackupCommand extends Command<void> with Disposable {
  TeamBackupCommand() {
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
  final description = "Get backup of your team app code from Discloud";

  @override
  final aliases = const ["bkp"];

  HttpClient? _client;
  File? _file;
  SpeedMonitor? _monitor;

  @override
  Future<void> run() async {
    final appId = argResults!.option("app");

    final spinner = context.printer.spin(text: "Fetching backup...");

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
    final client = _client = .new();
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
  }

  Future<void> _download({
    required String dir,
    required ISpin spinner,
    required Uri uri,
    HttpClient? client,
  }) async {
    final filename = uri.pathSegments.last;
    final filepath = "$dir$_pSep$filename";

    final file = _file = .new(filepath);
    final monitor = _monitor = .new();

    try {
      spinner.start("Downloading...");

      await download(
        uri,
        file: file,
        client: client,
        onProgress: (processed, total) {
          spinner.text = formatProgressMessage(
            prefixText: "Downloading:",
            speed: monitor.add(processed),
            direction: .down,
            processed: processed,
            total: total,
          );
        },
      );

      // no delete on dispose
      _file = null;

      spinner.success(filepath);
    } catch (e, s) {
      spinner.fail(resolveResponseMessage(e));
      context.printer.debug(s);
    }
  }

  @override
  Future<void> dispose() async {
    _client?.close();
    await _file?.safeDelete();
    _monitor?.dispose();
  }
}
