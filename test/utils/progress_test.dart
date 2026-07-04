import "package:discloud/utils/progress.dart";
import "package:test/test.dart";

void main() {
  group("formatProgressMessage", () {
    test("handles unknown totals", () {
      expect(
        formatProgressMessage(processed: 1024, total: -1),
        contains("1.0 KB"),
      );
    });
  });
}
