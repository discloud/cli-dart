part of "cli_spin.dart";

class _TimerCLISpin extends CLISpin {
  static String? _resolveSuffixText(Stopwatch stopwatch) {
    if (stopwatch.isRunning) return stopwatch.elapsed.pretty().dim();
    return null;
  }

  _TimerCLISpin._({String? text})
    : _stopwatch = .new()..start(),
      _timer = .new(.zero, _noop),
      super._(.new(text: text)) {
    _timerDuration = .new(milliseconds: _spin.interval);
  }

  final Stopwatch _stopwatch;

  Timer _timer;
  late final Duration _timerDuration;

  void _setSuffixTextAndStopTimers() {
    _timer.cancel();
    _spin.suffixText = _resolveSuffixText(_stopwatch);
    _stopwatch.stop();
  }

  void _timerCallback(_) {
    _spin.suffixText = _resolveSuffixText(_stopwatch);
  }

  @override
  void fail([String? text]) {
    _setSuffixTextAndStopTimers();
    super.fail(text);
  }

  @override
  void info([String? text]) {
    _setSuffixTextAndStopTimers();
    super.info(text);
  }

  @override
  void start([String? text]) {
    _stopwatch.resetAndStart();
    _timer.cancel();
    _timer = .periodic(_timerDuration, _timerCallback);
    super.start(text);
  }

  @override
  void stop() {
    _timer.cancel();
    super.stop();
    _stopwatch.stopAndReset();
  }

  @override
  void stopAndPersist({String? symbol, String? text}) {
    _timer.cancel();
    super.stopAndPersist(symbol: symbol, text: text);
    _stopwatch.stop();
  }

  @override
  void success([String? text]) {
    _setSuffixTextAndStopTimers();
    super.success(text);
  }

  @override
  void warn([String? text]) {
    _setSuffixTextAndStopTimers();
    super.warn(text);
  }
}
