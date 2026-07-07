import "package:args/args.dart";
import "package:args/command_runner.dart";

const _whiteSpace = " ";

extension ArgResultsExtension on ArgResults {
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
    if (optionOrRest(name, after) case final value?) return value;

    throw UsageException("Missing required option or argument: $name", "");
  }

  int requiredIntOptionOrRest(
    String name, [
    Iterable<String> after = const [],
  ]) {
    final raw = requiredOptionOrRest(name, after);
    if (int.tryParse(raw) case final value?) return value;

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
    if (multiOptionOrRest(name, after) case final values?
        when values.isNotEmpty) {
      return values;
    }

    throw UsageException("Missing required option or argument: $name", "");
  }

  bool wasNotParsed(String name) {
    return !wasParsed(name);
  }
}

extension NullableArgResultsExtension on ArgResults? {
  String? get commandName {
    final list = <String>[];

    ArgResults? command = this;
    while (command != null) {
      if (command.name case final name?) list.add(name);
      command = command.command;
    }

    if (list.isEmpty) return null;

    return list.join(_whiteSpace);
  }
}
