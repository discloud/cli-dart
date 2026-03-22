import "dart:isolate";

extension IsolateExtension on Isolate {
  static const String _mainIsolateDebugName = "main";

  bool get isMain => debugName == _mainIsolateDebugName;
}
