part of "console_printer.dart";

class _DebugConsolePrinter extends ConsolePrinter {
  _DebugConsolePrinter() : super._();

  void _debugSpin(CLISpin spin, Object? object) {
    spin.stop();
    stderr.writeln(object);
    spin.start();
  }

  @override
  void debug(Object? object) {
    if (_spin case final spin?) return _debugSpin(spin, object);
    stderr.writeln(object);
  }
}
