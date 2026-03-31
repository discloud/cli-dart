import "dart:convert";
import "dart:io";

import "package:args/command_runner.dart";
import "package:discloud/version.dart";

Future<void> commands({required CommandRunner runner}) async {
  final visited = <Command<void>>{};

  const version = packageVersion == "0.0.0" ? "" : " v$packageVersion";

  final buffer = StringBuffer("""
# [CLI Documentation$version](index.md)

## [Commands](commands.md)
""");

  for (final command in runner.commands.values) {
    const level = 3;

    final prefix = "".padRight(level, "#");

    buffer.writeln("\n$prefix ${command.name}");

    if (command.usage case final String usage when usage.isNotEmpty) {
      buffer.writeln("\n```sh\n${_removeLastLine(usage)}\n```");
    }

    _recursiveDocsGenerate(
      buffer,
      visited,
      command.subcommands,
      command.name,
      level + 1,
    );
  }

  final file = File("docs/commands.md");
  await file.create(recursive: true);
  await file.writeAsString(buffer.toString());
}

void _recursiveDocsGenerate(
  StringBuffer buffer,
  Set<Command<void>> visited,
  Map<String, Command<void>> subcommands,
  String fullName,
  int level,
) {
  for (final command in subcommands.values) {
    if (visited.contains(command)) continue;
    visited.add(command);

    final prefix = "".padRight(level, "#");

    final actualName = "$fullName ${command.name}";

    buffer.writeln("\n$prefix $actualName");

    if (command.usage case final String usage when usage.isNotEmpty) {
      buffer.writeln("\n```sh\n${_removeLastLine(usage)}\n```");
    }

    _recursiveDocsGenerate(
      buffer,
      visited,
      command.subcommands,
      actualName,
      level + 1,
    );
  }
}

String _removeLastLine(String text) {
  final lines = const LineSplitter().convert(text)..removeLast();

  while (lines.lastOrNull?.isEmpty ?? false) {
    lines.removeLast();
  }

  return lines.join("\n");
}
