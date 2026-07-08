import "package:args/args.dart";

const _whiteSpace = " ";

extension ArgResultsExtension on ArgResults {
  int? intOption(String name, {int? radix}) {
    if (option(name) case final s?) return .tryParse(s, radix: radix);
    return null;
  }

  int? intOptionOrRest(
    String name, {
    Iterable<String> after = const [],
    int? radix,
  }) {
    if (optionOrRest(name, after) case final value?) {
      return .tryParse(value, radix: radix);
    }
    return null;
  }

  Iterable<String>? multiOptionOrRest(
    String name, [
    Iterable<String> after = const [],
  ]) {
    if (wasParsed(name)) return multiOption(name);
    final index = after.where(wasNotParsed).length;
    if (rest.length > index) return rest.skip(index);
    return null;
  }

  String? optionOrRest(String name, [Iterable<String> after = const []]) {
    if (wasParsed(name)) return option(name);
    final index = after.where(wasNotParsed).length;
    if (rest.length > index) return rest[index];
    return null;
  }

  int requiredIntOptionOrRest(
    String name, {
    Iterable<String> after = const [],
    int? radix,
  }) {
    final raw = requiredOptionOrRest(name, after);
    if (int.tryParse(raw, radix: radix) case final value?) return value;
    throw Exception("Invalid integer for $name: $raw");
  }

  Iterable<String> requiredMultiOptionOrRest(
    String name, [
    Iterable<String> after = const [],
  ]) {
    if (multiOptionOrRest(name, after) case final values?
        when values.isNotEmpty) {
      return values;
    }
    throw Exception("Missing required option or argument: $name");
  }

  String requiredOptionOrRest(
    String name, [
    Iterable<String> after = const [],
  ]) {
    if (optionOrRest(name, after) case final value?) return value;
    throw Exception("Missing required option or argument: $name");
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
