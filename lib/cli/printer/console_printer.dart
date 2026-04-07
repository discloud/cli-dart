import "dart:io";

import "package:cli_spin/cli_spin.dart";
import "package:discloud/cli/context.dart";
import "package:discloud/cli/printer/iprinter.dart";

class ConsolePrinter implements IPrinter<CliSpin> {
  static final CliContext _context = .I;
  CliSpin? _spin;

  @override
  void dispose() {
    _spin?.stop();
  }

  @override
  CliSpin spin({String? text}) {
    return (_spin ??= CliSpin(text: text)).start();
  }

  @override
  void debug(Object? object) {
    if (!_context.isDebug) return;
    if (_spin case final spin?) {
      spin.info(object.toString());
      return;
    }
    stderr.writeln(object);
  }

  @override
  void error(Object? object) {
    if (_spin case final spin?) {
      spin.fail(object.toString());
      return;
    }
    stderr.writeln(object);
  }

  @override
  void info(Object? object) {
    if (_spin case final spin?) {
      spin.info(object.toString());
      return;
    }
    writeln(object);
  }

  @override
  void success(Object? object) {
    if (_spin case final spin?) {
      spin.success(object.toString());
      return;
    }
    writeln(object);
  }

  @override
  void warn(Object? object) {
    if (_spin case final spin?) {
      spin.warn(object.toString());
      return;
    }
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
