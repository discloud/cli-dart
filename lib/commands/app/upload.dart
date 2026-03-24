import "dart:isolate";

import "package:args/command_runner.dart";
import "package:cli_spin/cli_spin.dart";
import "package:discloud/extensions/command.dart";
import "package:discloud/extensions/file.dart";
import "package:discloud/services/discloud/constants.dart";
import "package:discloud/utils/messages.dart";
import "package:discloud_config/discloud_config.dart";
import "package:glob_zipper/glob_zipper.dart";
import "package:path/path.dart" as p;

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

    final configFilePath = p.joinAll([directory.path, DiscloudConfig.filename]);

    final DiscloudConfig config = await .fromPath(configFilePath);

    await config.validate();

    final glob = argResults!.multiOption("glob");

    final spinner = CliSpin().start("Zipping...");

    final file = await Isolate.run(() async {
      final zipper = GlobZipper(
        directory: directory,
        tempDirectory: directory,
        patterns: glob,
        ignore: allBlockedFiles,
        ignoreFilename: ".discloudignore",
      );

      return zipper.zip();
    });

    spinner.start("Uploading...");

    try {
      final response = await context.api.postMultipart("/upload", file: file);
      spinner.success(resolveResponseMessage(response));
    } catch (e, s) {
      spinner.fail(resolveResponseMessage(e));
      context.debug(s);
    } finally {
      await file.safeDelete();
    }
  }
}
