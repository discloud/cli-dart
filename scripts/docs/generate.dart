import "dart:io";

import "package:discloud/extensions/iterable.dart";

void main() async {
  final exitCodes = await Future.wait([
    _run("dart", ["run", "scripts/docs/generate_home.dart"]),
    _run("dart", ["run", "scripts/docs/generate_commands.dart"]),
  ]);

  exit(exitCodes.sum());
}

Future<int> _run(String executable, List<String> arguments) async {
  final result = await Process.run(executable, arguments);

  if (result.stdout case final String text when text.isNotEmpty) {
    stdout.writeln(text);
  }

  if (result.stderr case final String text when text.isNotEmpty) {
    stderr.writeln(text);
  }

  return result.exitCode;
}
