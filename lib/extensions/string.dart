import "package:intl/intl.dart";

extension StringExtension on String {
  String capitalize([String? locale]) =>
      toBeginningOfSentenceCase(this, locale);

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
  static const _empty = "";

  String get orEmpty => this ?? _empty;
}
