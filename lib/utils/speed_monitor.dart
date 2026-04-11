import "dart:collection";

import "package:discloud/cli/disposable.dart";

final class _SpeedSample with LinkedListEntry<_SpeedSample> {
  _SpeedSample(this.units) : time = DateTime.now().microsecondsSinceEpoch;

  final int units;
  final int time;
}

/// A utility class for monitoring processing speed over a sliding time window.
///
/// It tracks the number of units processed over a specified [windowDuration] 
/// (defaulting to 1 second) and calculates the current speed.
class SpeedMonitor implements Disposable {
  static const double _zero = 0;

  /// Creates a [SpeedMonitor] with a given [windowDuration].
  SpeedMonitor({this.windowDuration = const .new(seconds: 1)})
    : _samples = .new();

  /// The duration of the sliding window used for speed calculation.
  final Duration windowDuration;

  /// A linked list of samples currently within the time window.
  final LinkedList<_SpeedSample> _samples;

  @override
  void dispose() {
    _samples.clear();
  }

  /// Adds a sample of the [totalProcessedUnits] and returns the current speed.
  ///
  /// The speed is calculated as units per [windowDuration].
  /// It automatically removes samples that are older than the [windowDuration].
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
