import "package:discloud/cli/runner.dart";

import "generate/commands.dart";
import "generate/home.dart";

void main() async {
  final runner = CliCommandRunner();

  await Future.wait([
    generateHome(),
    generateCommands(runner),
  ]);
}
