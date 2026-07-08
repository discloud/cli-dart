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
import "package:path/path.dart" hide context;

final class SnapshotDownloadCommand extends Command<void> with Disposable {
  SnapshotDownloadCommand() {
    argParser
      ..addOption("app")
      ..addOption("version", help: "Snapshot version in YYYYMMDD-HHMMSS format")
      ..addOption(
        "dir",
        abbr: "d",
        aliases: const ["out"],
        help:
            "Specifies the destination path for downloading backups. The destination path will be considered a directory.",
      );
  }

  @override
  final name = "download";

  @override
  final description = "Download a versioned snapshot of your app";

  @override
  final aliases = const ["dl"];

  File? _file;
  HttpClient? _client;
  SpeedMonitor? _monitor;

  @override
  Future<void> run() async {
    final String appId = argResults!.requiredOptionOrRest("app");

    final spinner = context.printer.spin();

    final version = await _retrieveSnapshotVersion(appId, spinner: spinner);

    spinner.text = "Fetching snapshot download url...";

    final response = await context.api.get(
      "/snapshot/$appId/versions/$version",
    );

    spinner.success(resolveResponseMessage(response));

    if (response["download"]?["url"] case final String url) {
      await _download(spinner: spinner, uri: .parse(url));
    }
  }

  Future<String> _retrieveSnapshotVersion(
    String appId, {
    required ISpin spinner,
  }) async {
    if (argResults!.optionOrRest("version", const ["app"])
        case final String version) {
      return version;
    }

    spinner.text = "Retrieving snapshot...";

    if (await context.api.get("/snapshot/$appId") case final Map r) {
      if (r["versions"] case final List versions when versions.isNotEmpty) {
        if (versions.first case final Map version) {
          if (version["version"] case final String value) return value;
        }
      }
    }

    spinner.text = "Creating snapshot...";

    if (await context.api.post("/snapshot/$appId") case final Map r) {
      if (r["snapshot"] case final Map snapshot) {
        if (snapshot["version"] case final String value) return value;
      }
    }

    throw Exception("Failed to retrieve an app snapshot version");
  }

  Future<void> _download({required ISpin spinner, required Uri uri}) async {
    final filename = uri.pathSegments.last;
    final filepath = joinAll([?argResults!.option("dir"), filename]);
    final file = _file = .new(filepath);

    final monitor = _monitor = .new();

    try {
      spinner.start("Downloading...");

      await download(
        uri,
        file: file,
        client: _client,
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
    _monitor?.dispose();
    await _file?.safeDelete();
  }
}
