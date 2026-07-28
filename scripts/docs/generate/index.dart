import "dart:io";

Future<void> home({required String header}) async {
  final buffer = StringBuffer(header);

  final file = File("docs/index.md");
  await file.create(recursive: true);
  await file.writeAsString(buffer.toString());
}
