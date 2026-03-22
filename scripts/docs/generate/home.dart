import "dart:io";

Future<void> generateHome() async {
  final buffer = StringBuffer()
    ..write("""
# [CLI Documentation](docs.md)

## [Commands](commands.md)
""");

  final file = File("docs/docs.md");
  await file.create(recursive: true);
  await file.writeAsString(buffer.toString());
}
