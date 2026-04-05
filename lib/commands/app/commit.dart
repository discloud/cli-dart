import "dart:async";
import "dart:io";

import "package:args/command_runner.dart";
import "package:cli_spin/cli_spin.dart";
import "package:discloud/extensions/command.dart";
import "package:discloud/extensions/file.dart";
import "package:discloud/services/discloud/constants.dart";
import "package:discloud/utils/messages.dart";
import "package:discloud/utils/percent.dart";
import "package:discloud/utils/zip.dart";
import "package:discloud_config/discloud_config.dart";
import "package:path/path.dart" as p;

class AppCommitCommand extends Command<void> {
  AppCommitCommand() {
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

    final spinner = CliSpin().start("Zipping...");

    final file = await zip(
      directory: directory,
      glob: glob,
      ignore: allBlockedFiles,
      onData: (progress) {
        spinner.text = formatZipProgress(progress, directory);
      },
    );

    final fileStat = await file.stat();
    final total = fileStat.size;

    spinner.start("Committing...");

    try {
      final response = await context.api.putMultipart(
        "/app/$appId/commit",
        file: file,
        onUploadProgress: (processed) {
          spinner.start("Committing... ${percent(processed, total)}%");
        },
        onUploadDone: () {
          spinner.start("Processing...");
        },
      );

      spinner.success(resolveResponseMessage(response));
    } catch (e, s) {
      spinner.fail(resolveResponseMessage(e));
      context.debug(s);
    } finally {
      await file.safeDelete();
    }
  }

  Future<String?> _getDiscloudConfigAppId(Directory directory) async {
    final configFilePath = p.joinAll([directory.path, DiscloudConfig.filename]);

    final DiscloudConfig config = await .fromPath(configFilePath);

    return config.appId;
  }
}
