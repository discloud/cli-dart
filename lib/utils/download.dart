import "dart:io";

typedef VoidCallback = void Function({int current, int processed, int total});

Future<void> download(
  String url,
  String out, {
  HttpClient? client,
  VoidCallback? onProgress,
}) async {
  final client_ = client ?? HttpClient();
  final file = File(out);
  await file.create(recursive: true);
  final sink = file.openWrite();

  try {
    final request = await client_.getUrl(.parse(url));

    final response = await request.close();

    if (onProgress case final onProgress?) {
      await _downloadWithProgress(
        onProgress: onProgress,
        response: response,
        sink: sink,
      );
    } else {
      await sink.addStream(response);
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

Future<void> _downloadWithProgress({
  required VoidCallback onProgress,
  required HttpClientResponse response,
  required IOSink sink,
}) async {
  final total = response.contentLength;

  int processed = 0;
  await for (final data in response) {
    sink.add(data);

    onProgress(
      current: data.length,
      processed: processed += data.length,
      total: total,
    );
  }
}
