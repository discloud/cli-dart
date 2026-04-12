import "package:discloud/utils/bytes.dart";
import "package:test/test.dart";

void main() {
  group("Bytes", () {
    test("1KB", () {
      const Bytes bytes = .new(1024);
      expect(bytes.toString(), "1.0KB");
    });

    test("1MB", () {
      const Bytes bytes = .new(1024 * 1024);
      expect(bytes.toString(), "1.0MB");
    });
  });

  group("Bits", () {
    test("1KB > 8.0Kb", () {
      const Bytes bytes = .bits(1024);
      expect(bytes.toString(), "8.0Kb");
    });

    test("128KB > 1.0Mb", () {
      const Bytes bytes = .bits(1024 * 1024 / 8);
      expect(bytes.toString(), "1.0Mb");
    });

    test("8MB > 1Mb", () {
      const Bytes bytes = .bits(1024 * 1024);
      expect(bytes.toString(), "8.0Mb");
    });

    test("10MB > 80Mb", () {
      const Bytes bytes = .bits(1024 * 1024 * 10);
      expect(bytes.toString(), "80.0Mb");
    });
  });
}
