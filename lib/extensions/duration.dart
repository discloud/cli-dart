import "dart:io";

import "package:duration/duration.dart";
import "package:duration/locale.dart";
import "package:intl/intl.dart";

extension DurationExtension on Duration {
  static final DurationLocale _durationLocale =
      .fromLanguageCode(Platform.localeName) ??
      .fromLanguageCode(Intl.shortLocale(Platform.localeName)) ??
      const EnglishDurationLocale();

  String pretty({
    bool abbreviated = true,
    String? conjunction,
    String? delimiter = " ",
    DurationLocale? locale,
    int maxUnits = 0,
    String? spacer = "",
    DurationTersity tersity = .millisecond,
    DurationTersity upperTersity = .day,
  }) => prettyDuration(
    this,
    abbreviated: abbreviated,
    conjunction: conjunction,
    delimiter: delimiter,
    locale: locale ?? _durationLocale,
    maxUnits: maxUnits,
    spacer: spacer,
    tersity: tersity,
    upperTersity: upperTersity,
  );
}
