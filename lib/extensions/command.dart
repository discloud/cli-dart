import "package:args/command_runner.dart";
import "package:discloud/cli/context.dart";

extension CommandExtension<T> on Command<T> {
  CliContext get context => .I;

  void addSubcommnads(Iterable<Command<T>> iterable) {
    for (final command in iterable) {
      addSubcommand(command);
    }
  }

  String? optionOrRest(String name, int index) {
    final parsed = argResults?.wasParsed(name) ?? false;
    if (parsed) {
      final value = argResults?.option(name);
      if (value != null && value.isNotEmpty) return value;
    }

    final rest = argResults?.rest ?? const <String>[];
    if (rest.length > index) return rest[index];

    final value = argResults?.option(name);
    if (value != null && value.isNotEmpty) return value;

    return null;
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
    final rest = argResults?.rest ?? const <String>[];
    if (rest.length > index) return rest.skip(index).toList();

    final values = argResults?.multiOption(name) ?? const <String>[];
    if (values.isNotEmpty) return values;

    return defaults;
  }
}
