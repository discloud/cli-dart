import "package:tabular/tabular.dart";

String mapToVerticalAsciiTable(
  Map data, [
  Set<String> keysToIgnore = const {},
]) {
  final List<List<dynamic>> rows = [];

  for (final entry in data.entries) {
    if (keysToIgnore.contains(entry.key)) continue;
    rows.add([
      entry.key,
      switch (entry.value) {
        final List value => value.length,
        _ => entry.value,
      },
    ]);
  }

  return tabular(rows, rowDividers: const [], border: .all);
}

String listToAsciiTable(
  List<dynamic> list, [
  Set<String> keysToIgnore = const {},
]) {
  final keys = [];
  final List<List<dynamic>> rows = [keys];

  keys.addAll(["#", ...list[0].keys.where((k) => !keysToIgnore.contains(k))]);

  for (int i = 0; i < list.length; i++) {
    final data = list[i];
    final row = <dynamic>[i + 1];
    rows.add(row);

    for (final entry in data.entries) {
      if (keysToIgnore.contains(entry.key)) continue;
      row.add(switch (entry.value) {
        final List value => value.length,
        _ => entry.value,
      });
    }
  }

  return tabular(rows);
}
