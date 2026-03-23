import "dart:io";

import "package:discloud/version.dart";

Future<void> home() async {
  final buffer = StringBuffer("""
# [CLI Documentation v$packageVersion](index.md)

## [Commands](commands.md)
""");

  final file = File("docs/index.md");
  await file.create(recursive: true);
  await file.writeAsString(buffer.toString());
}
