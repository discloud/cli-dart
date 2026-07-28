import "dart:async";
import "dart:io";

import "package:args/command_runner.dart";
import "package:path/path.dart";

Future<void> commands({
  required String header,
  required CommandRunner runner,
}) async {
  final visited = <Command<void>>{};

  final StringBuffer buffer = .new(header)
    ..writeln()
    ..writeln("## [Commands](commands.md)")
    ..writeln();

  header = buffer.toString();

  for (final command in runner.commands.values) {
    if (command.hidden || !visited.add(command)) continue;

    buffer.writeln("- [${command.name}](commands_${command.name}.md)");

    await _recursiveDocsGenerate(
      command: command,
      header: header,
      visited: visited,
    );
  }

  if (runner.commands.isNotEmpty) buffer.writeln();

  buffer
    ..writeln("```sh")
    ..writeln(runner.usage)
    ..writeln("```");

  final File file = .new(joinAll(["docs", "commands.md"]));
  await file.writeAsString(buffer.toString());
}

Future<void> _recursiveDocsGenerate({
  required Command<void> command,
  required String header,
  required Set<Command<void>> visited,
  String? parentCommandName,
}) async {
  final StringBuffer buffer = .new(header);

  if (parentCommandName case final String name) {
    buffer
      ..writeAll([
        "### [$name](commands_${name.replaceAll(" ", "_")}.md)",
        "[${command.name}](commands_${command.name.replaceAll(" ", "_")}.md)",
      ], " / ")
      ..writeln()
      ..writeln();
  } else {
    buffer
      ..writeln(
        "### [${command.name}](commands_${command.name.replaceAll(" ", "_")}.md)",
      )
      ..writeln();
  }

  final commandName = [?parentCommandName, command.name].join(" ");

  final fileCommandName = "commands_${commandName.replaceAll(" ", "_")}";

  final File file = .new("docs/$fileCommandName.md");

  for (final subcommand in command.subcommands.values) {
    if (subcommand.hidden || !visited.add(subcommand)) continue;

    final subcommandName = [commandName, subcommand.name].join(" ");

    final fileSubcommandName =
        "commands_${subcommandName.replaceAll(" ", "_")}";

    buffer.writeln("- [${subcommand.name}]($fileSubcommandName.md)");

    await _recursiveDocsGenerate(
      command: subcommand,
      header: header,
      visited: visited,
      parentCommandName: commandName,
    );
  }

  if (command.subcommands.isNotEmpty) buffer.writeln();

  buffer
    ..writeln("```sh")
    ..writeln(command.usage)
    ..writeln("```");

  await file.writeAsString(buffer.toString());
}
