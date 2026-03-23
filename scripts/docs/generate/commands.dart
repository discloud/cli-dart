import "dart:io";

import "package:args/command_runner.dart";
import "package:discloud/version.dart";

Future<void> commands({required CommandRunner runner}) async {
  final visited = <Command<void>>{};

  final buffer = StringBuffer("""
# [CLI Documentation v$packageVersion](index.md)

## [Commands](commands.md)
""");

  for (final command in runner.commands.values) {
    final level = 3;

    final prefix = "".padRight(level, "#");

    buffer.writeln("\n$prefix ${command.name}");

    if (command.usage case final String usage when usage.isNotEmpty) {
      buffer.writeln("\n```sh\n$usage\n```");
    }

    recursiveDocsGenerate(
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

void recursiveDocsGenerate(
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
      buffer.writeln("\n```sh\n$usage\n```");
    }

    recursiveDocsGenerate(
      buffer,
      visited,
      command.subcommands,
      actualName,
      level + 1,
    );
  }
}
