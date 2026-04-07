import "package:discloud/cli/disposable.dart";

abstract interface class IPrinter<Spin> implements Disposable {
  Spin spin({String? text, bool start = true});

  /// [info] alias
  void call(Object? object);

  /// If there is a spin, it will continue after writing to the console.
  void debug(Object? object);

  /// This use spin if exists
  /// This use stderr instead stdout
  void error(Object? object);

  /// This use spin if exists
  void info(Object? object);

  /// This use spin if exists
  void success(Object? object);

  /// This use spin if exists
  void warn(Object? object);

  void write(Object? object);
  void writeAll(Iterable<dynamic> objects, [String sep = ""]);
  void writeCharCode(int charCode);
  void writeln(Object? object);
}
