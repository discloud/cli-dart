// dart scripts/docs/generate.dart

import "dart:io";
import "dart:typed_data";

import "package:args/command_runner.dart";
import "package:discloud/cli/runner.dart";
import "package:discloud/version.dart";
import "package:path/path.dart";

import "generate/commands.dart";
import "generate/index.dart";
import "markdown_to_html_converter.dart";

const _docsRootPath = "docs";

void main() async {
  final docRootDir = Directory(_docsRootPath);

  const filesToPreserve = {"_config.yml"};
  final filesToPreserveContents = <File, Uint8List>{};

  for (final filename in filesToPreserve) {
    final File file = .new(joinAll([_docsRootPath, filename]));
    if (!await file.exists()) continue;

    filesToPreserveContents[file] = await file.readAsBytes();
  }

  await docRootDir.delete(recursive: true);
  await docRootDir.create(recursive: true);

  for (final entry in filesToPreserveContents.entries) {
    await entry.key.writeAsBytes(entry.value, flush: true);
  }

  const version = packageVersion == "0.0.0" ? "" : " v$packageVersion";

  const header = "# [CLI Documentation$version](index.md)\n";

  final CommandRunner<void> runner = CliCommandRunner();

  await Future.wait([
    home(header: header),
    commands(header: header, runner: runner),
  ]);

  final converter = MarkdownToHtmlConverter(directory: docRootDir);

  await for (final (file, content) in converter.convert()) {
    await file.writeAsString(content);
  }
}
