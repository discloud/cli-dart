import "dart:io";

import "package:args/command_runner.dart";
import "package:discloud/cli/runner.dart";

void main() async {
  final runner = CliCommandRunner();

  final visited = <Command<void>>{};

  final buffer = StringBuffer()..write("""
# [CLI Documentation](docs.md)

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

    buffer.writeln("\n$prefix $fullName ${command.name}");

    if (command.usage case final String usage when usage.isNotEmpty) {
      buffer.writeln("\n```sh\n$usage\n```");
    }

    recursiveDocsGenerate(
      buffer,
      visited,
      command.subcommands,
      "$fullName ${command.name}",
      level + 1,
    );
  }
}
