import "dart:async";

import "package:cli_spin/cli_spin.dart";
import "package:discloud/cli/spin/ispin.dart";
import "package:discloud/extensions/duration.dart";
import "package:tint/tint.dart";

part "timer_cli_spin.dart";

const _defaultTimerInterval = 100;

void _noop() {}

class CLISpin implements ISpin {
  factory CLISpin({String? text, bool showDuration = false}) =>
      showDuration ? _TimerCliSpin._(text: text) : ._(.new(text: text));

  const CLISpin._(this._spin);

  final CliSpin _spin;

  @override
  String get text => _spin.text;

  @override
  set text(String text) {
    _spin.text = text;
  }

  @override
  void fail([String? text]) {
    _spin.fail(text);
  }

  @override
  void info([String? text]) {
    _spin.info(text);
  }

  @override
  void start([String? text]) {
    _spin.start(text);
  }

  @override
  void stop() {
    _spin.stop();
  }

  @override
  void stopAndPersist({String? symbol, String? text}) {
    _spin.stopAndPersist(symbol: symbol, text: text);
  }

  @override
  void success([String? text]) {
    _spin.success(text);
  }

  @override
  void warn([String? text]) {
    _spin.warn(text);
  }
}
