import "dart:collection";

import "package:discloud/cli/disposable.dart";

final class _SpeedSample with LinkedListEntry<_SpeedSample> {
  _SpeedSample(this.bytes, this.time);

  final int bytes;
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

  double add(int totalProcessedBytes) {
    final now = DateTime.now().microsecondsSinceEpoch;

    final _SpeedSample last = .new(totalProcessedBytes, now);

    _samples.add(last);

    _SpeedSample first = _samples.first;
    while (now - first.time > windowDuration.inMicroseconds) {
      _samples.first.unlink();
      first = first.next!;
    }

    final deltaTime = (last.time - first.time) / Duration.microsecondsPerSecond;

    if (deltaTime <= _zero) return _zero;

    final deltaBytes = last.bytes - first.bytes;

    return deltaBytes / deltaTime;
  }
}
