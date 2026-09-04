// dart scripts/docs/generate.dart

import "dart:io";

import "package:args/command_runner.dart";
import "package:discloud/cli/runner.dart";
import "package:discloud/version.dart";

import "directory_extension.dart";
import "generate/commands.dart";
import "generate/index.dart";
import "markdown_to_html_converter.dart";

const _docsRootPath = "docs";
const _filenamesToPreserve = {"_config.yml"};

void main() async {
  final docRootDir = Directory(_docsRootPath);

  await docRootDir.recreate(filenamesToPreserve: _filenamesToPreserve);

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
