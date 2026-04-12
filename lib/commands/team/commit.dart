import "dart:io";

import "package:args/command_runner.dart";
import "package:discloud/extensions/command.dart";
import "package:discloud/extensions/file.dart";
import "package:discloud/services/discloud/constants.dart";
import "package:discloud/utils/messages.dart";
import "package:discloud/utils/progress.dart";
import "package:discloud/utils/speed_monitor.dart";
import "package:discloud/utils/zip.dart";
import "package:discloud_config/discloud_config.dart";
import "package:path/path.dart" hide context;

class TeamCommitCommand extends Command<void> {
  TeamCommitCommand() {
    argParser
      ..addOption(
        "app",
        help: "App id (This can be omitted to use the discloud.config file)",
      )
      ..addMultiOption("glob", abbr: "g", defaultsTo: const ["**"]);
  }

  @override
  final name = "commit";

  @override
  final description = "Commit one app or site to Discloud";

  @override
  final aliases = const ["c"];

  @override
  Future<void> run() async {
    final directory = context.workspaceFolder;

    final appId =
        argResults!.option("app") ?? await _getDiscloudConfigAppId(directory);

    if (appId == null) throw Exception("Missing app id");

    final glob = argResults!.multiOption("glob");

    final spinner = context.printer.spin(text: "Zipping...");

    final zipath = joinAll([directory.path, "${basename(directory.path)}.zip"]);

    final File file = .new(zipath);

    await zip(
      directory: directory,
      zipfile: file,
      glob: glob,
      ignore: allBlockedFiles,
      onData: (progress) {
        spinner.text = formatZipProgress(progress, directory);
      },
    );

    final fileStat = await file.stat();
    final total = fileStat.size;

    final monitor = SpeedMonitor();

    try {
      spinner.start("Committing...");

      final response = await context.api.putMultipart(
        "/team/$appId/commit",
        file: file,
        onUploadProgress: (processed) {
          spinner.text = formatProgressMessage(
            speed: monitor.add(processed),
            prefixText: "Committing:",
            symbol: .up,
            processed: processed,
            total: total,
          );
        },
        onUploadDone: () {
          spinner.start("Processing...");
        },
      );

      spinner.success(resolveResponseMessage(response));
    } finally {
      await file.safeDelete();
      monitor.dispose();
    }
  }

  Future<String?> _getDiscloudConfigAppId(Directory directory) async {
    final configFilePath = joinAll([directory.path, DiscloudConfig.filename]);

    final DiscloudConfig config = await .fromPath(configFilePath);

    return config.appId;
  }
}
