import "package:discloud/cli/spin/cli_spin.dart";

abstract interface class const ISpin() {
  factory cli({String? text, bool showDuration = false}) =>
      CLISpin(text: text, showDuration: showDuration);

  abstract String text;

  void fail([String? text]);

  void info([String? text]);

  void start([String? text]);

  void stop();

  void stopAndPersist({String? symbol, String? text});

  void success([String? text]);

  void warn([String? text]);
}
