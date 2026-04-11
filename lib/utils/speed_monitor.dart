import "dart:collection";

final class SpeedSample with LinkedListEntry<SpeedSample> {
  final int bytes;
  final int time;

  SpeedSample(this.bytes, this.time);
}

class SpeedMonitor {
  static const double _zero = 0;
  final Duration windowDuration;
  final LinkedList<SpeedSample> _samples;

  SpeedMonitor({this.windowDuration = const .new(seconds: 1)})
    : _samples = .new();

  double add(int totalProcessedBytes) {
    final now = DateTime.now().microsecondsSinceEpoch;

    final SpeedSample last = .new(totalProcessedBytes, now);

    _samples.add(last);

    while (now - _samples.first.time > windowDuration.inMicroseconds) {
      _samples.first.unlink();
    }

    final first = _samples.first;

    final deltaTime = (last.time - first.time) / Duration.microsecondsPerSecond;

    if (deltaTime <= _zero) return _zero;

    final deltaBytes = last.bytes - first.bytes;

    return deltaBytes / deltaTime;
  }
}
