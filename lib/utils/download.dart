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

    if (onProgress case final onProgress?) {
      await _downloadWithProgress(
        onProgress: onProgress,
        responseFactory: request.close,
        sink: sink,
      );
    } else {
      await sink.addStream(await request.close());
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
  required Future<HttpClientResponse> Function() responseFactory,
  required IOSink sink,
}) async {
  final response = await responseFactory();

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
