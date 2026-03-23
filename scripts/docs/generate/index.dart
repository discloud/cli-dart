import "dart:io";

import "package:discloud/version.dart";

Future<void> home() async {
  final version = packageVersion == "0.0.0" ? "" : " v$packageVersion";

  final buffer = StringBuffer("""
# [CLI Documentation$version](index.md)

## [Commands](commands.md)
""");

  final file = File("docs/index.md");
  await file.create(recursive: true);
  await file.writeAsString(buffer.toString());
}
