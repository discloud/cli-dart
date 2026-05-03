import "dart:async";

import "package:discloud/cli/disposable.dart";

extension ListDisposableExtension on List<Disposable> {
  Future<void> dispose() {
    final futures = <Future<void>>[];

    removeWhere((item) {
      if (item.dispose() case final Future future) futures.add(future);
      return true;
    });

    return futures.wait;
  }
}

extension ListStreamSubscriptionExtension<T> on List<StreamSubscription<T>> {
  Future<void> cancel() {
    final futures = <Future<void>>[];

    removeWhere((item) {
      futures.add(item.cancel());
      return true;
    });

    return futures.wait;
  }
}
