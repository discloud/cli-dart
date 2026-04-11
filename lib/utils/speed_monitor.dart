import "dart:collection";

import "package:discloud/cli/disposable.dart";

final class _SpeedSample with LinkedListEntry<_SpeedSample> {
  _SpeedSample(this.units) : time = DateTime.now().microsecondsSinceEpoch;

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
    final _SpeedSample last = .new(totalProcessedUnits);

    _samples.add(last);

    _SpeedSample first = _samples.first;

    if (first == last) return _zero;

    while (last.time - first.time > windowDuration.inMicroseconds) {
      first.unlink();
      first = _samples.first;
    }

    final baseDeltaTime = last.time - first.time;

    final deltaTime = baseDeltaTime / windowDuration.inMicroseconds;

    final deltaUnits = last.units - first.units;

    return deltaUnits / deltaTime;
  }
}
