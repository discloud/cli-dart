import "package:intl/intl.dart";

extension StringExtension on String {
  String capitalize([String? locale]) =>
      toBeginningOfSentenceCase(this, locale);

  int sumCodeUnits() => codeUnits.reduce((a, b) => a + b);

  String intl({
    String? desc,
    Map<String, Object>? examples,
    String? locale,
    String? name,
    List<Object>? args,
    String? meaning,
    bool? skip,
  }) => Intl.message(
    this,
    desc: desc,
    examples: examples,
    locale: locale,
    name: name,
    args: args,
    meaning: meaning,
    skip: skip,
  );
}

extension NullableStringExtension on String? {
  String get orEmpty => this ?? "";
}
