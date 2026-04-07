import "package:discloud/cli/disposable.dart";

abstract interface class IPrinter<Spin> implements Disposable {
  Spin spin({String? text});

  void debug(Object? object);
  void error(Object? object);
  void info(Object? object);
  void success(Object? object);
  void warn(Object? object);
  void write(Object? object);
  void writeAll(Iterable<dynamic> objects, [String sep = ""]);
  void writeCharCode(int charCode);
  void writeln(Object? object);
}
