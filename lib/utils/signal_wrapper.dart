import "dart:async";
import "dart:io";

import "package:discloud/extensions/list.dart";

typedef OnDisposeCallback = FutureOr<void> Function();
typedef OnSignalCallback = FutureOr<void> Function(ProcessSignal signal);

final class const _Cancelled() implements Exception;

abstract class SignalWrapper {
  factory multi(
    Iterable<ProcessSignal> signals, {
    OnDisposeCallback? onDispose,
    OnSignalCallback? onSignal,
  }) => _MultiSignalWrapper(
    signals,
    onDispose: onDispose,
    onSignal: onSignal,
    completer: .new(),
  );

  factory(
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

class const _MultiSignalWrapper(
  final Iterable<ProcessSignal> _signals, {
  required final Completer<Null> _completer,
  @override final OnDisposeCallback? onDispose,
  @override final OnSignalCallback? onSignal,
}) implements SignalWrapper {
  @override
  bool get signed => _completer.isCompleted;

  @override
  Future<T?> call<T>(Future<T> Function() fn) async {
    final futures = <Future>[];
    final subscriptions = [
      for (final signal in _signals)
        signal.watch().listen((signal) {
          if (!_completer.isCompleted) {
            _completer.completeError(const _Cancelled());
          }
          if (onSignal?.call(signal) case final Future f) futures.add(f);
        }),
    ];

    try {
      return await Future.any([_completer.future, fn()]);
    } on _Cancelled catch (_) {
      return null;
    } catch (_) {
      rethrow;
    } finally {
      await onDispose?.call();
      await futures.wait;
      await subscriptions.cancel();
    }
  }
}

class const _SingleSignalWrapper(
  final ProcessSignal _signal, {
  required final Completer<Null> _completer,
  @override final OnDisposeCallback? onDispose,
  @override final OnSignalCallback? onSignal,
}) implements SignalWrapper {
  @override
  bool get signed => _completer.isCompleted;

  @override
  Future<T?> call<T>(Future<T> Function() fn) async {
    final futures = <Future>[];
    final subscription = _signal.watch().listen((signal) {
      if (!_completer.isCompleted) {
        _completer.completeError(const _Cancelled());
      }
      if (onSignal?.call(signal) case final Future future) futures.add(future);
    });

    try {
      return await Future.any([_completer.future, fn()]);
    } on _Cancelled catch (_) {
      return null;
    } catch (_) {
      rethrow;
    } finally {
      await onDispose?.call();
      await futures.wait;
      await subscription.cancel();
    }
  }
}
