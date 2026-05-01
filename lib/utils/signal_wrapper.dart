import "dart:async";
import "dart:io";

class SignalWrapper {
  SignalWrapper(this.signal) : _completer = .new();

  final ProcessSignal signal;
  final Completer<Null> _completer;

  bool get signed => _completer.isCompleted;

  Future<T?> run<T>(
    Future<T> Function() fn, {
    FutureOr<void> Function()? dispose,
  }) async {
    final subscription = signal.watch().listen(_onData);

    try {
      return await Future.any([_completer.future, fn()]);
    } catch (_) {
      rethrow;
    } finally {
      await dispose?.call();
      await subscription.cancel();
    }
  }

  void _onData(ProcessSignal signal) {
    if (signed) return;
    _completer.complete(null);
  }
}
