import "dart:collection";

import "package:discloud/cli/disposable.dart";

final class _SpeedSample with LinkedListEntry<_SpeedSample> {
  _SpeedSample(this.units, this.time);

  final int units;
  final int time;
}

class SpeedMonitor implements Disposable {
  static const double _zero = 0;

  SpeedMonitor({this.windowDuration = const .new(seconds: 1)})
    : _samples = .new();

  final Duration windowDuration;
  final LinkedList<_SpeedSample> _samples;

  @override
  void dispose() {
    _samples.clear();
  }

  double add(int totalProcessedUnits) {
    final now = DateTime.now().microsecondsSinceEpoch;

    final _SpeedSample last = .new(totalProcessedUnits, now);

    _samples.add(last);

    _SpeedSample first = _samples.first;
    while (now - first.time > windowDuration.inMicroseconds) {
      first.unlink();
      first = _samples.first;
    }

    final deltaTime = (last.time - first.time) / Duration.microsecondsPerSecond;

    if (deltaTime <= _zero) return _zero;

    final deltaUnits = last.units - first.units;

    return deltaUnits / deltaTime;
  }
}
