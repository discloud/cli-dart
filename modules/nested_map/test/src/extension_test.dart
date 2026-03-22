import "package:nested_map/nested_map.dart";
import "package:test/test.dart";

void main() {
  final map = <String, dynamic>{};

  const key = "abc.def.ghi";
  const value = "jkl";

  test("Testing nested map", () {
    map.set(key, value);
    expect(map.get(key), value);
  });
}
