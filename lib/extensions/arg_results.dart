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

extension ArgResultsExtension on ArgResults {
  String? optionOrRest(String name, [Iterable<String> after = const []]) {
    if (wasParsed(name)) return option(name);

    final index = after.where((name) => !wasParsed(name)).length;

    if (rest.length > index) return rest[index];

    return null;
  }

  List<String> multiOptionOrRest(
    String name, {
    Iterable<String> after = const [],
    List<String> Function()? defaultFactory,
  }) {
    if (wasParsed(name)) return multiOption(name);

    final index = after.where((name) => !wasParsed(name)).length;

    if (rest.length > index) return rest.skip(index).toList();

    return defaultFactory?.call() ?? [];
  }
}
