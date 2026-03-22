import "package:duration/duration.dart";
import "package:duration/locale.dart";

extension DurationExtension on Duration {
  String pretty({
    bool abbreviated = true,
    String? conjunction,
    String? delimiter = " ",
    DurationLocale locale = const EnglishDurationLocale(),
    int maxUnits = 0,
    String? spacer = "",
    DurationTersity tersity = .millisecond,
    DurationTersity upperTersity = .day,
  }) => prettyDuration(
    this,
    abbreviated: abbreviated,
    conjunction: conjunction,
    delimiter: delimiter,
    locale: locale,
    maxUnits: maxUnits,
    spacer: spacer,
    tersity: tersity,
    upperTersity: upperTersity,
  );
}
