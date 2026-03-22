import "package:args/command_runner.dart";
import "package:discloud/cli/context.dart";

extension CommandExtension<T> on Command<T> {
  CliContext get context => .I;

  void addSubcommnads(Iterable<Command<T>> iterable) {
    for (final command in iterable) {
      addSubcommand(command);
    }
  }
}
