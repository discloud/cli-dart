import "package:args/command_runner.dart";
import "package:discloud/cli/context.dart";

extension CommandRunnerExtension<T> on CommandRunner<T> {
  CliContext get context => .I;

  void addCommands(Iterable<Command<T>> iterable) {
    for (final command in iterable) {
      addCommand(command);
    }
  }
}
