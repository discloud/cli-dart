extension DateTimeExtension on DateTime {
  int get secondsSinceEpoch =>
      microsecondsSinceEpoch ~/ Duration.microsecondsPerSecond;
}
