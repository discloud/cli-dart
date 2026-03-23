import "dart:io";

Future<void> download(String url, String out, {HttpClient? client}) async {
  final client_ = client ?? HttpClient();
  final file = File(out);
  await file.create(recursive: true);
  final sink = file.openWrite();

  try {
    final request = await client_.getUrl(.parse(url));

    final response = await request.close();

    await for (final data in response) {
      sink.add(data);
    }

    await sink.close();
  } catch (_) {
    await sink.close();
    await file.delete();
    rethrow;
  } finally {
    if (client == null) client_.close();
  }
}
