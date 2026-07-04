import "dart:async";
import "dart:io";

import "package:args/command_runner.dart";
import "package:discloud/cli/disposable.dart";
import "package:discloud/extensions/command.dart";
import "package:discloud/extensions/file.dart";
import "package:discloud/utils/download.dart";
import "package:discloud/utils/messages.dart";
import "package:discloud/utils/progress.dart";
import "package:discloud/utils/speed_monitor.dart";

const _pSep = "/";

final class SnapshotDownloadCommand extends Command<void> with Disposable {
  SnapshotDownloadCommand() {
    argParser
      ..addOption("app", mandatory: true)
      ..addOption(
        "version",
        mandatory: true,
        help: "Snapshot version in YYYYMMDD-HHMMSS format",
      )
      ..addOption(
        "dir",
        abbr: "d",
        aliases: const ["out"],
        help:
            "Specifies the destination path for downloading the snapshot. The destination path will be considered a directory.",
        defaultsTo: ".",
      );
  }

  @override
  final name = "download";

  @override
  final description = "Download a versioned snapshot of your app";

  @override
  final aliases = const ["dl"];

  HttpClient? _client;
  File? _file;
  SpeedMonitor? _monitor;

  @override
  Future<void> run() async {
    final String appId = argResults!.option("app")!;
    final String version = argResults!.option("version")!;
    final String dir = argResults!.option("dir")!;

    final spinner = context.printer.spin(text: "Fetching download url...");

    final response = await context.api.get(
      "/snapshot/$appId/versions/$version",
    );

    spinner.success(resolveResponseMessage(response));

    final String url = response["download"]["url"];

    final Uri uri = Uri.parse(url);

    final filename = uri.pathSegments.last;
    final filepath = "$dir$_pSep$filename";
    final file = _file = File(filepath);

    final client = _client = HttpClient();
    final monitor = _monitor = SpeedMonitor();

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
            direction: UnitDirection.down,
            processed: processed,
            total: total,
          );
        },
      );

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
    _monitor?.dispose();
    await _file?.safeDelete();
  }
}
