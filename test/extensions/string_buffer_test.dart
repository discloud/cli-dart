import "package:discloud/extensions/string_buffer.dart";
import "package:test/test.dart";

void main() {
  const separator = " ";

  group("writeAllCapitalized", () {
    test("void", () {
      final buffer = StringBuffer()..writeAllCapitalized(const [], separator);
      expect(buffer.toString(), "");
    });

    test("null", () {
      final buffer = StringBuffer()
        ..writeAllCapitalized(const [null, null, null], separator);
      expect(buffer.toString(), "");
    });

    test("text", () {
      final buffer = StringBuffer()
        ..writeAllCapitalized(const [null, "first", "last"], separator);
      expect(buffer.toString(), "First last");
    });
  });
}
