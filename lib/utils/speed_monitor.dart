import "dart:collection";

import "package:discloud/cli/disposable.dart";

final class _SpeedSample extends LinkedListEntry<_SpeedSample> {
  _SpeedSample(this.units) : time = DateTime.now().microsecondsSinceEpoch;

  final int time;
  final int units;
}

/// A utility class for monitoring processing speed over a sliding time window.
class SpeedMonitor implements Disposable {
  static const double _zero = 0;

  /// Creates a [SpeedMonitor]
  factory SpeedMonitor() => ._(queue: .new());

  const SpeedMonitor._({
    required this._queue,
    this._windowDuration = const .new(seconds: 1),
  });

  final LinkedList<_SpeedSample> _queue;
  final Duration _windowDuration;

  @override
  void dispose() {
    _queue.clear();
  }

  /// Adds a sample of the [totalProcessedUnits] and returns the current speed.
  double add(int totalProcessedUnits) {
    final _SpeedSample last = .new(totalProcessedUnits);

    _queue.add(last);

    _SpeedSample first = _queue.first;

    if (first == last) return _zero;

    int baseDeltaTime = last.time - first.time;

    while (baseDeltaTime > _windowDuration.inMicroseconds) {
      first.unlink();
      first = _queue.first;
      baseDeltaTime = last.time - first.time;
    }

    return (last.units - first.units) /
        (baseDeltaTime / _windowDuration.inMicroseconds);
  }
}
