import "package:args/command_runner.dart";

extension CommandRunnerExtension<T> on CommandRunner<T> {
  void addCommands(Iterable<Command<T>> iterable) {
    for (final command in iterable) {
      addCommand(command);
    }
  }
}
