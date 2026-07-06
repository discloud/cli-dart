import "package:args/args.dart";
import "package:args/command_runner.dart";
import "package:discloud/cli/context.dart";

extension ArgResultsExtension on ArgResults {
  String? optionOrRest(String name, int index) {
    if (wasParsed(name)) {
      final value = option(name);
      if (value != null && value.isNotEmpty) return value;
    }

    if (rest.length > index) return rest[index];

    final value = option(name);
    if (value != null && value.isNotEmpty) return value;

    return null;
  }

  List<String> multiOptionOrRest(
    String name,
    int index, {
    List<String> defaults = const [],
  }) {
    if (wasParsed(name)) {
      final values = multiOption(name);
      if (values.isNotEmpty) return values;
    }

    if (rest.length > index) return rest.skip(index).toList();

    final values = multiOption(name);
    if (values.isNotEmpty) return values;

    return defaults;
  }

  int restIndexAfter(Iterable<String> previousOptions) =>
      previousOptions.where((name) => !wasParsed(name)).length;
}

extension CommandExtension<T> on Command<T> {
  CliContext get context => .I;

  void addSubcommnads(Iterable<Command<T>> iterable) {
    for (final command in iterable) {
      addSubcommand(command);
    }
  }

  String? optionOrRest(String name, int index) {
    return argResults?.optionOrRest(name, index);
  }

  String requiredOptionOrRest(String name, int index) {
    final value = optionOrRest(name, index);
    if (value != null) return value;

    usageException("Missing required option or argument: $name");
  }

  int requiredIntOptionOrRest(String name, int index) {
    final raw = requiredOptionOrRest(name, index);
    final value = int.tryParse(raw);
    if (value != null) return value;

    usageException("Invalid integer for $name: $raw");
  }

  List<String> multiOptionOrRest(
    String name,
    int index, {
    List<String> defaults = const [],
  }) {
    return argResults?.multiOptionOrRest(name, index, defaults: defaults) ??
        defaults;
  }
}
