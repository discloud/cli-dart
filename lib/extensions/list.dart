import "dart:async";

import "package:discloud/cli/disposable.dart";

extension ListDisposableExtension on List<Disposable> {
  Future<void> dispose() async {
    final futures = <Future<void>>[];

    removeWhere((item) {
      if (item.dispose() case final Future<void> future) futures.add(future);
      return true;
    });

    await futures.wait;
  }
}
