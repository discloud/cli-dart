import "package:discloud/utils/ascii_table.dart";
import "package:test/test.dart";

void main() {
  group("ascii table", () {
    test("empty maps do not throw", () {
      expect(mapToVerticalAsciiTable(const {}), "");
    });

    test("empty lists do not throw", () {
      expect(listToAsciiTable(const []), "");
    });

    test("scalar lists do not throw", () {
      expect(listToAsciiTable(const ["ok"]), contains("ok"));
    });
  });
}
