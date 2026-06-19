import "dart:io";

import "package:discloud/cli/printer/iprinter.dart";
import "package:discloud/cli/spin/cli_spin.dart";
import "package:discloud/cli/spin/ispin.dart";

part "debug_console_printer.dart";

class ConsolePrinter implements IPrinter<ISpin> {
  factory ConsolePrinter._debug() = _DebugConsolePrinter;

  factory ConsolePrinter({bool isDebug = false}) => isDebug ? ._debug() : ._();

  ConsolePrinter._();

  ISpin? _spin;

  @override
  void dispose() {
    _spin?.stop();
  }

  @override
  ISpin spin({String? text, bool start = true, bool showDuration = true}) {
    final spin = _spin ??= CLISpin(text: text, showDuration: showDuration);
    if (start) spin.start();
    return spin;
  }

  @override
  void call(Object? object) {
    return info(object);
  }

  @override
  void debug(Object? object) {}

  @override
  void error(Object? object) {
    if (_spin case final spin?) return spin.fail(object.toString());
    stderr.writeln(object);
  }

  @override
  void info(Object? object) {
    if (_spin case final spin?) return spin.info(object.toString());
    writeln(object);
  }

  @override
  void success(Object? object) {
    if (_spin case final spin?) return spin.success(object.toString());
    writeln(object);
  }

  @override
  void warn(Object? object) {
    if (_spin case final spin?) return spin.warn(object.toString());
    writeln(object);
  }

  @override
  void write(Object? object) {
    stdout.write(object);
  }

  @override
  void writeAll(Iterable<dynamic> objects, [String sep = ""]) {
    stdout.writeAll(objects, sep);
  }

  @override
  void writeCharCode(int charCode) {
    stdout.writeCharCode(charCode);
  }

  @override
  void writeln(Object? object) {
    stdout.writeln(object);
  }
}
