part of "cli_spin.dart";

class _TimerCliSpin extends CLISpin {
  _TimerCliSpin._({String? text})
    : _stopwatch = .new()..start(),
      super._(.new(text: text)) {
    _interval = _spin.spinner?.interval ?? _defaultTimerInterval;
    _timerInterval = .new(milliseconds: _interval);
    _timer = .new(.zero, _noop);
  }

  final Stopwatch _stopwatch;

  late final int _interval;
  late final Duration _timerInterval;
  late Timer _timer;

  void _resetSuffixText() {
    _spin.suffixText = null;
  }

  void _setSuffixText([_]) {
    _spin.suffixText = _stopwatch.elapsed.pretty().dim();
  }

  @override
  void fail([String? text]) {
    _timer.cancel();
    _setSuffixText();
    super.fail(text);
    _resetSuffixText();
  }

  @override
  void info([String? text]) {
    _timer.cancel();
    _setSuffixText();
    super.info(text);
    _resetSuffixText();
  }

  @override
  void start([String? text]) {
    _timer.cancel();
    _stopwatch.reset();
    _timer = .periodic(_timerInterval, _setSuffixText);
    super.start(text);
  }

  @override
  void stop() {
    _timer.cancel();
    super.stop();
    _stopwatch.stop();
    _resetSuffixText();
  }

  @override
  void stopAndPersist({String? symbol, String? text}) {
    _timer.cancel();
    super.stopAndPersist(symbol: symbol, text: text);
    _stopwatch.stop();
    _resetSuffixText();
  }

  @override
  void success([String? text]) {
    _timer.cancel();
    _setSuffixText();
    super.success(text);
    _resetSuffixText();
  }

  @override
  void warn([String? text]) {
    _timer.cancel();
    _setSuffixText();
    super.warn(text);
    _resetSuffixText();
  }
}
