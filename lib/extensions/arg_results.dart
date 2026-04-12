import "package:args/args.dart";

extension NullableArgResultsExtension on ArgResults? {
  String? get commandName {
    final list = <String>[];

    ArgResults? command = this;
    while (command != null) {
      if (command.name case final name?) list.add(name);
      command = command.command;
    }

    if (list.isEmpty) return null;

    return list.join(" ");
  }
}
