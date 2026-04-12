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

class AppUploadCommand extends Command<void> {
  AppUploadCommand() {
    argParser.addMultiOption("glob", abbr: "g", defaultsTo: const ["**"]);
  }

  @override
  final name = "upload";

  @override
  final description = "Upload one app or site to Discloud";

  @override
  final aliases = const ["up"];

  @override
  Future<void> run() async {
    final directory = context.workspaceFolder;

    final configFilePath = joinAll([directory.path, DiscloudConfig.filename]);

    final DiscloudConfig config = await .fromPath(configFilePath);

    await config.validate();

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
      spinner.start("Uploading...");

      final response = await context.api.postMultipart(
        "/upload",
        file: file,
        onUploadProgress: (processed) {
          spinner.text = formatProgressMessage(
            speed: monitor.add(processed),
            prefixText: "Uploading:",
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
}
