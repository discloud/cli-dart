import "dart:collection";

import "package:discloud/cli/disposable.dart";

final class _SpeedSample with LinkedListEntry<_SpeedSample> {
  _SpeedSample(this.units) : time = DateTime.now().microsecondsSinceEpoch;

  final int units;
  final int time;
}

/// A utility class for monitoring processing speed over a sliding time window.
class SpeedMonitor implements Disposable {
  static const double _zero = 0;

  /// Creates a [SpeedMonitor]
  factory SpeedMonitor() => ._(samples: .new());

  const SpeedMonitor._({
    required this._samples,
    this._windowDuration = const .new(seconds: 1),
  });

  /// The duration of the sliding window used for speed calculation.
  final Duration _windowDuration;

  /// A linked list of samples currently within the time window.
  final LinkedList<_SpeedSample> _samples;

  @override
  void dispose() {
    _samples.clear();
  }

  /// Adds a sample of the [totalProcessedUnits] and returns the current speed.
  double add(int totalProcessedUnits) {
    final _SpeedSample last = .new(totalProcessedUnits);

    _samples.add(last);

    _SpeedSample first = _samples.first;

    if (first == last) return _zero;

    int baseDeltaTime = last.time - first.time;

    while (baseDeltaTime > _windowDuration.inMicroseconds) {
      first.unlink();
      first = _samples.first;
      baseDeltaTime = last.time - first.time;
    }

    final deltaTime = baseDeltaTime / _windowDuration.inMicroseconds;

    final deltaUnits = last.units - first.units;

    return deltaUnits / deltaTime;
  }
}
