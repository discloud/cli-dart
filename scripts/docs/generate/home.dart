import "dart:io";

import "package:discloud/version.dart";

Future<void> home() async {
  final buffer = StringBuffer()
    ..write("""
# [CLI Documentation v$packageVersion](docs.md)

## [Commands](commands.md)
""");

  final file = File("docs/docs.md");
  await file.create(recursive: true);
  await file.writeAsString(buffer.toString());
}
