import "package:discloud/extensions/string.dart";

extension StringBufferExtension on StringBuffer {
  void writeAllCapitalized(Iterable objects, [String separator = ""]) {
    final iterator = objects.iterator;
    while (iterator.moveNext() && iterator.current == null) {}
    if (iterator.current == null) return;
    write(iterator.current.toString().capitalize());
    while (iterator.moveNext()) {
      write("$separator${iterator.current}");
    }
  }
}
