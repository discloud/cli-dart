import "dart:io";

typedef VoidProgressCallback = void Function(int processed, int total);

Future<void> download(
  String url, {
  String? out,
  HttpClient? client,
  VoidProgressCallback? onProgress,
}) async {
  final uri = Uri.parse(url);
  out ??= uri.pathSegments.last;

  final file = File(out);
  await file.create(recursive: true);
  final sink = file.openWrite();

  final client_ = client ?? .new();

  try {
    final request = await client_.getUrl(uri);

    if (onProgress case final onProgress?) {
      await _downloadWithProgress(
        onProgress: onProgress,
        responseFactory: request.close,
        sink: sink,
      );
    } else {
      final response = await request.close();
      await sink.addStream(response);
    }
  } catch (_) {
    await sink.close();
    await file.delete();
    rethrow;
  } finally {
    await sink.close();
    if (client == null) client_.close();
  }
}

Future<void> _downloadWithProgress({
  required VoidProgressCallback onProgress,
  required Future<HttpClientResponse> Function() responseFactory,
  required IOSink sink,
}) async {
  final response = await responseFactory();

  final total = response.contentLength;

  int processed = 0;
  await for (final data in response) {
    sink.add(data);

    onProgress(processed += data.length, total);
  }
}
