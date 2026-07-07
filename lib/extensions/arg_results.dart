import "package:args/args.dart";
import "package:args/command_runner.dart";

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
  bool wasNotParsed(String name) {
    return !wasParsed(name);
  }

  String? optionOrRest(String name, [Iterable<String> after = const []]) {
    if (wasParsed(name)) return option(name);

    final index = after.where(wasNotParsed).length;

    if (rest.length > index) return rest[index];

    return null;
  }

  String requiredOptionOrRest(
    String name, [
    Iterable<String> after = const [],
  ]) {
    final value = optionOrRest(name, after);
    if (value != null) return value;

    throw UsageException("Missing required option or argument: $name", "");
  }

  int requiredIntOptionOrRest(
    String name, [
    Iterable<String> after = const [],
  ]) {
    final raw = requiredOptionOrRest(name, after);
    final value = int.tryParse(raw);
    if (value != null) return value;

    throw UsageException("Invalid integer for $name: $raw", "");
  }

  List<String>? multiOptionOrRest(
    String name, [
    Iterable<String> after = const [],
  ]) {
    if (wasParsed(name)) return multiOption(name);

    final index = after.where(wasNotParsed).length;

    if (rest.length > index) return rest.skip(index).toList();

    return null;
  }

  List<String> requiredMultiOptionOrRest(
    String name, [
    Iterable<String> after = const [],
  ]) {
    final values = multiOptionOrRest(name, after);
    if (values != null && values.isNotEmpty) return values;

    throw UsageException("Missing required option or argument: $name", "");
  }
}
