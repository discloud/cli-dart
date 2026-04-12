import "dart:async";

import "package:discloud/cli/disposable.dart";

extension ListDisposableExtension on List<Disposable> {
  Future<void> dispose() async {
    final futures = <Future>[];

    removeWhere((item) {
      if (item.dispose() case final Future future) futures.add(future);
      return true;
    });

    await futures.wait;
  }
}
