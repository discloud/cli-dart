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

  Future<T?> call<T>(Future<T> Function() fn);
}

class _MultiSignalWrapper implements SignalWrapper {
  const _MultiSignalWrapper(
    this._signals, {
    required this._completer,
    this.onSignal,
    this.onDispose,
  });

  final Iterable<ProcessSignal> _signals;
  final Completer<Null> _completer;

  @override
  final OnDisposeCallback? onDispose;

  @override
  final OnSignalCallback? onSignal;

  @override
  bool get signed => _completer.isCompleted;

  @override
  Future<T?> call<T>(Future<T> Function() fn) async {
    final futures = <Future>[];
    final subscriptions = [
      for (final signal in _signals)
        signal.watch().listen((signal) {
          if (!_completer.isCompleted) _completer.complete(null);
          if (onSignal?.call(signal) case final Future f) futures.add(f);
        }),
    ];

    try {
      return await Future.any([_completer.future, fn()]);
    } catch (_) {
      rethrow;
    } finally {
      await onDispose?.call();
      await futures.wait;
      await subscriptions.cancel();
    }
  }
}

class _SingleSignalWrapper implements SignalWrapper {
  const _SingleSignalWrapper(
    this._signal, {
    required this._completer,
    this.onDispose,
    this.onSignal,
  });

  final ProcessSignal _signal;
  final Completer<Null> _completer;

  @override
  final OnDisposeCallback? onDispose;

  @override
  final OnSignalCallback? onSignal;

  @override
  bool get signed => _completer.isCompleted;

  @override
  Future<T?> call<T>(Future<T> Function() fn) async {
    final futures = <Future>[];
    final subscription = _signal.watch().listen((signal) {
      if (!_completer.isCompleted) _completer.complete(null);
      if (onSignal?.call(signal) case final Future future) futures.add(future);
    });

    try {
      return await Future.any([_completer.future, fn()]);
    } catch (_) {
      rethrow;
    } finally {
      await onDispose?.call();
      await futures.wait;
      await subscription.cancel();
    }
  }
}
