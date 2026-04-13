import "package:discloud/extensions/string.dart";

extension StringBufferExtension on StringBuffer {
  void writeAllCapitalized(Iterable objects, [String separator = ""]) {
    final iterator = objects.iterator;

    while (iterator.moveNext()) {
      if (iterator.current case final current?) {
        write(current.toString().capitalize());
        break;
      }
    }

    while (iterator.moveNext()) {
      write("$separator${iterator.current}");
    }
  }
}
