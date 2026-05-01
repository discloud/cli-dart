import "dart:async";

abstract mixin class Disposable {
  FutureOr<void> dispose();
}
