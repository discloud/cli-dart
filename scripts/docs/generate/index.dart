import "dart:io";

Future<void> home({required String header}) async {
  final StringBuffer buffer = .new(header)
    ..writeln()
    ..writeAll(["## [Commands](commands.md)"], "\n")
    ..writeln();

  final file = File("docs/index.md");
  await file.create(recursive: true);
  await file.writeAsString(buffer.toString());
}
