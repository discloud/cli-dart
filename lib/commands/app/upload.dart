import "dart:io";

import "package:args/command_runner.dart";
import "package:discloud/cli/disposable.dart";
import "package:discloud/extensions/command.dart";
import "package:discloud/extensions/file.dart";
import "package:discloud/services/discloud/constants.dart";
import "package:discloud/utils/messages.dart";
import "package:discloud/utils/progress.dart";
import "package:discloud/utils/speed_monitor.dart";
import "package:discloud/utils/zip.dart";
import "package:discloud_config/discloud_config.dart";
import "package:path/path.dart" hide context;

final _configLineBreakPattern = RegExp(r"[\r\n]");

final class AppUploadCommand extends Command<void> with Disposable {
  AppUploadCommand() {
    argParser.addMultiOption("glob", abbr: "g", defaultsTo: const ["**"]);
  }

  @override
  final name = "upload";

  @override
  final description = "Upload one app or site to Discloud";

  @override
  final aliases = const ["create", "up"];

  File? _file;
  SpeedMonitor? _monitor;

  @override
  Future<void> run() async {
    final directory = context.workspaceFolder;

    final configFilePath = joinAll([directory.path, DiscloudConfig.filename]);

    final DiscloudConfig config = await .fromPath(configFilePath);

    await config.validate();

    final glob = multiOptionOrRest("glob", 0, defaults: const ["**"]);

    final spinner = context.printer.spin(text: "Zipping...");

    final zipath = joinAll([directory.path, "${basename(directory.path)}.zip"]);

    final file = _file = .new(zipath);

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

    final monitor = _monitor = .new();

    spinner.start("Uploading...");

    final response = await context.api.postMultipart(
      "/upload",
      file: file,
      onUploadProgress: (processed) {
        spinner.text = formatProgressMessage(
          speed: monitor.add(processed),
          prefixText: "Uploading:",
          direction: .up,
          processed: processed,
          total: total,
        );
      },
      onUploadDone: () {
        spinner.start("Processing...");
      },
    );

    spinner.success(resolveResponseMessage(response));

    if (response["status"] == "ok") {
      if (response["app"] case final Map app) {
        final updates = <String, String>{};

        if (app["avatarURL"] case final String avatarURL) {
          updates["AVATAR"] = avatarURL;
        }

        if (app["id"] case final String id) updates["ID"] = id;

        await _updateConfigFile(File(configFilePath), updates);
      }
    }
  }

  Future<void> _updateConfigFile(File file, Map<String, String> updates) async {
    if (updates.isEmpty) return;

    final seen = <String>{};
    final lines = await file.readAsLines();

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final index = line.indexOf("=");
      if (index < 1) continue;

      final key = line.substring(0, index).trim();
      final value = updates[key];
      if (value == null) continue;

      lines[i] = "$key=${_configValue(value)}";
      seen.add(key);
    }

    for (final entry in updates.entries) {
      if (!seen.contains(entry.key)) {
        lines.add("${entry.key}=${_configValue(entry.value)}");
      }
    }

    await file.writeAsString("${lines.join("\n")}\n");
  }

  String _configValue(String value) {
    return value.replaceAll(_configLineBreakPattern, "");
  }

  @override
  Future<void> dispose() async {
    _monitor?.dispose();
    await _file?.safeDelete();
  }
}
