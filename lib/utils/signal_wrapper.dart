import "dart:async";
import "dart:io";

import "package:discloud/extensions/list.dart";

typedef OnDisposeCallback = FutureOr<void> Function();
typedef OnSignalCallback = FutureOr<void> Function(ProcessSignal signal);

abstract class SignalWrapper {
  factory SignalWrapper.multi(
    Iterable<ProcessSignal> signals, {
    OnDisposeCallback? onDispose,
    OnSignalCallback? onSignal,
  }) => _MultiSignalWrapper(
    signals,
    onDispose: onDispose,
    onSignal: onSignal,
    completer: .new(),
    subscriptions: [],
  );

  factory SignalWrapper(
    ProcessSignal signal, {
    OnSignalCallback? onSignal,
    OnDisposeCallback? onDispose,
  }) => _SingleSignalWrapper(
    signal,
    onDispose: onDispose,
    onSignal: onSignal,
    completer: .new(),
  );

  abstract final OnDisposeCallback? onDispose;
  abstract final OnSignalCallback? onSignal;

  bool get signed;

  Future<T?> run<T>(Future<T> Function() fn);
}

class _MultiSignalWrapper implements SignalWrapper {
  const _MultiSignalWrapper(
    this._signals, {
    required Completer<ProcessSignal> completer,
    required List<StreamSubscription<ProcessSignal>> subscriptions,
    this.onSignal,
    this.onDispose,
  }) : _completer = completer,
       _subscriptions = subscriptions;

  final Iterable<ProcessSignal> _signals;
  final List<StreamSubscription<ProcessSignal>> _subscriptions;
  final Completer<ProcessSignal> _completer;

  @override
  final OnDisposeCallback? onDispose;

  @override
  final OnSignalCallback? onSignal;

  @override
  bool get signed => _completer.isCompleted;

  @override
  // ignore: body_might_complete_normally_nullable
  Future<T?> run<T>(Future<T> Function() fn) async {
    for (final signal in _signals) {
      _subscriptions.add(signal.watch().listen(_onData));
    }

    try {
      final result = await Future.any([_completer.future, fn()]);
      if (result is! ProcessSignal) return result as T;
    } catch (_) {
      rethrow;
    } finally {
      await onDispose?.call();
      await _subscriptions.cancel();
    }
  }

  void _onData(ProcessSignal signal) {
    onSignal?.call(signal);
    if (signed) return;
    _completer.complete(signal);
  }
}

class _SingleSignalWrapper implements SignalWrapper {
  const _SingleSignalWrapper(
    this._signal, {
    required Completer<Null> completer,
    this.onDispose,
    this.onSignal,
  }) : _completer = completer;

  final ProcessSignal _signal;
  final Completer<Null> _completer;

  @override
  final OnDisposeCallback? onDispose;

  @override
  final OnSignalCallback? onSignal;

  @override
  bool get signed => _completer.isCompleted;

  @override
  Future<T?> run<T>(Future<T> Function() fn) async {
    final subscription = _signal.watch().listen(_onData);

    try {
      return await Future.any([_completer.future, fn()]);
    } catch (_) {
      rethrow;
    } finally {
      await onDispose?.call();
      await subscription.cancel();
    }
  }

  void _onData(ProcessSignal signal) {
    onSignal?.call(signal);
    if (signed) return;
    _completer.complete(null);
  }
}
