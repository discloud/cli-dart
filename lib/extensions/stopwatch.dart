extension StopwatchExtension on Stopwatch {
  void resetAndStart() {
    reset();
    start();
  }

  void stopAndReset() {
    stop();
    reset();
  }
}
